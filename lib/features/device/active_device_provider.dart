import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:v3/common/providers/base_provider.dart';
import 'package:v3/common/widgets/app_dialogs.dart';
import 'package:v3/core/navigation/nav_service.dart';
import 'package:v3/locator.dart';
import 'package:v3/features/device/repositories/device_repository.dart';
import 'package:v3/features/device/models/device_dto.dart';
import 'package:v3/features/device/models/device_thing_model.dart';

class ActiveDeviceProvider extends BaseProvider with WidgetsBindingObserver {
  final DeviceRepository _deviceRepo = locator<DeviceRepository>();
  StreamSubscription<String>? _repoSubscription;

  DeviceDto? _currentDevice;
  DeviceDto? get currentDevice => _currentDevice;

  final List<String> _autoModeOptions = ['1', '2', '3', '4', '5'];
  List<String> get autoModeOptions => _autoModeOptions;

  int get autoModeIndex {
    if (_currentDevice == null) return 0;
    int mins = _currentDevice!.autoModeDelaySeconds ~/ 60;
    int idx = _autoModeOptions.indexOf(mins.toString());
    return idx == -1 ? 0 : idx;
  }

  bool _hasNewFirmware = false;
  String _newFirmwareVersion = '';
  bool get hasNewFirmware => _hasNewFirmware;
  String get newFirmwareVersion => _newFirmwareVersion;

  String _currentTimeZoneId = 'Asia/Shanghai';
  String _currentTimeZoneOffset = 'UTC+08:00';
  String get currentTimeZoneId => _currentTimeZoneId;
  String get currentTimeZoneOffset => _currentTimeZoneOffset;

  int _savedCalibrationWeight = 5000;
  int get savedCalibrationWeight => _savedCalibrationWeight;

  bool get isNetworkGood => true;

  List<String> _localTimerList = [];
  List<String> get timerList => _localTimerList;

  ActiveDeviceProvider() {
    _repoSubscription = _deviceRepo.onDeviceUpdated.listen((updatedDeviceId) {
      if (_currentDevice != null && _currentDevice!.deviceId == updatedDeviceId) {
        notifyListeners();
      }
    });
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _repoSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (_currentDevice != null) {
        _deviceRepo.fetchDeviceProperties(_currentDevice!.deviceId).then((_) {
          notifyListeners();
        });
      }
    }
  }

  Future<void> selectDevice(String id) async {
    if (_currentDevice?.deviceId == id) return;
    _currentDevice = _deviceRepo.getDevice(id);
    _localTimerList = List.from(_currentDevice!.timerList);
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedCalibrationWeight = prefs.getInt('calibration_weight_$id') ?? 5000;
      _currentTimeZoneId = await FlutterTimezone.getLocalTimezone();
      _currentTimeZoneOffset = _calculateOffsetStr(_currentTimeZoneId);
    } catch (_) {}
    clearError();
    notifyListeners();
    final needsLoading = _currentDevice!.wifiMac == "00:00:00:00:00:00";
    if (needsLoading) setLoading(true);
    try {
      await _deviceRepo.fetchDeviceProperties(id);
      await _deviceRepo.fetchDeviceLogs(id, isLoadMore: false);
    } catch (e) {
      setError("Sync Error: $e");
    } finally {
      if (needsLoading) setLoading(false);
      notifyListeners();
    }
  }

  Future<void> setMode(WorkMode mode) async {
    if (_currentDevice == null) return;
    if (_currentDevice!.workMode == mode) return;
    final success = await _deviceRepo.setWorkMode(_currentDevice!.deviceId, mode);
    if (!success) setError("Failed to set mode");
  }

  Future<void> toggleDnd() async {
    if (_currentDevice == null) return;
    final targetState = !_currentDevice!.isDndEnabled;
    final success = await _deviceRepo.setDndStatus(_currentDevice!.deviceId, targetState);
    if (!success) setError("Failed to toggle Do Not Disturb");
  }

  Future<void> executeAction(ExecuteAction action) async {
    if (_currentDevice == null) return;
    final success = await _deviceRepo.executeAction(_currentDevice!.deviceId, action);
    if (!success) setError("Failed to execute action");
  }

  Future<void> toggleChildLock() async {
    if (_currentDevice == null) return;
    final targetState = !_currentDevice!.isChildLockEnabled;
    final success = await _deviceRepo.setChildLock(_currentDevice!.deviceId, targetState);
    if (!success) setError("Failed to toggle child lock");
  }

  void updateAutoMode(int index) async {
    if (_currentDevice == null) return;
    int minutes = int.parse(_autoModeOptions[index]);
    int seconds = minutes * 60;
    final success = await _deviceRepo.setAutoModeDelay(_currentDevice!.deviceId, seconds);
    if (success) {
      _currentDevice!.updateAttributesFromMap({DeviceThingModel.autoModeDelay.dpid: seconds.toString()});
      notifyListeners();
    } else {
      setError("Failed to update auto mode");
    }
  }

  void setDndTime(String start, String end) async {
    if (_currentDevice == null) return;
    int startSec = _timeToSeconds(start);
    int endSec = _timeToSeconds(end);
    final success = await _deviceRepo.setDndTimeRange(_currentDevice!.deviceId, startSec, endSec);
    if (!success) setError("Failed to set DND time");
  }

  void setTimeZone(String tzId, String offsetStr) {
    _currentTimeZoneId = tzId;
    _currentTimeZoneOffset = offsetStr;
    notifyListeners();
  }

  void addTimer(String timeStr) {
    _localTimerList.add(timeStr);
    _localTimerList.sort();
    notifyListeners();
  }

  void removeTimer(int index) {
    _localTimerList.removeAt(index);
    notifyListeners();
  }

  Future<void> submitTimers() async {
    if (_currentDevice == null) return;
    setLoading(true);
    final secondsArray = _localTimerList.map((time) => _timeToSeconds(time)).toList();
    final success = await _deviceRepo.submitTimers(_currentDevice!.deviceId, secondsArray);
    if (success)
      showSuccessToast("Success");
    else
      setError("Error");
    setLoading(false);
  }

  Future<bool> startCalibrationStep1() async {
    if (_currentDevice == null) return false;
    setLoading(true);
    final success = await _deviceRepo.startCalibrationStep1(_currentDevice!.deviceId);
    setLoading(false);
    if (!success) setError("Failed");
    return success;
  }

  Future<bool> submitCalibrationStep3(int weightGrams) async {
    if (_currentDevice == null) return false;
    setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('calibration_weight_${_currentDevice!.deviceId}', weightGrams);
      _savedCalibrationWeight = weightGrams;
    } catch (_) {}
    final success = await _deviceRepo.submitCalibrationStep3(_currentDevice!.deviceId, weightGrams);
    setLoading(false);
    if (!success) setError("Failed");
    return success;
  }

  Future<void> resetWifi() async {
    if (_currentDevice == null) return;
    setLoading(true);
    final success = await _deviceRepo.resetWifi(_currentDevice!.deviceId);
    setLoading(false);
    if (success)
      showSuccessToast("Reset Wi-Fi command sent");
    else
      setError("Failed to reset Wi-Fi");
  }

  Future<bool> startFirmwareUpgrade() async {
    return true;
  }

  Future<bool> updateDeviceName(String newName) async {
    if (_currentDevice == null) return false;
    _currentDevice!.deviceName = newName;
    notifyListeners();
    return true;
  }

  void showSuccessToast(String message) {
    NavService.rootNavigatorKey.currentContext?.showAppToast(message: message, type: AppToastType.success);
  }

  int _timeToSeconds(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 3600 + m * 60;
  }

  String _calculateOffsetStr(String tzName) {
    try {
      final location = tz.getLocation(tzName);
      final offset = tz.TZDateTime.now(location).timeZoneOffset;
      final hours = offset.inHours;
      final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final sign = hours >= 0 ? '+' : '-';
      return 'UTC$sign${hours.abs().toString().padLeft(2, '0')}:$minutes';
    } catch (e) {
      return 'UTC+00:00';
    }
  }
}
