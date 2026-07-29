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
  /// 设备数据仓库实例
  final DeviceRepository _deviceRepo = locator<DeviceRepository>();

  /// 设备更新事件订阅
  StreamSubscription<String>? _repoSubscription;

  /// 当前选中的设备对象
  DeviceDto? _currentDevice;

  /// 获取当前选中的设备对象
  DeviceDto? get currentDevice => _currentDevice;

  /// 自动模式延迟时间选项列表（单位：分钟）
  final List<String> _autoModeOptions = ['1', '2', '3', '4', '5'];

  /// 获取自动模式延迟时间选项列表
  List<String> get autoModeOptions => _autoModeOptions;

  /// 获取当前设备对应的自动模式选项索引
  int get autoModeIndex {
    if (_currentDevice == null) return 0;
    int mins = _currentDevice!.autoModeDelaySeconds ~/ 60;
    int idx = _autoModeOptions.indexOf(mins.toString());
    return idx == -1 ? 0 : idx;
  }

  /// 是否有新固件可供升级
  bool _hasNewFirmware = false;

  /// 新固件版本号
  String _newFirmwareVersion = '';

  /// 获取是否有新固件
  bool get hasNewFirmware => _hasNewFirmware;

  /// 获取新固件版本号
  String get newFirmwareVersion => _newFirmwareVersion;

  /// 当前设备时区标识标识（如：Asia/Shanghai）
  String _currentTimeZoneId = 'Asia/Shanghai';

  /// 当前设备时区偏移量字符串（如：UTC+08:00）
  String _currentTimeZoneOffset = 'UTC+08:00';

  /// 获取当前时区标识
  String get currentTimeZoneId => _currentTimeZoneId;

  /// 获取当前时区偏移量字符串
  String get currentTimeZoneOffset => _currentTimeZoneOffset;

  /// 本地保存的校准砝码重量（单位：克）
  int _savedCalibrationWeight = 5000;

  /// 获取保存的校准砝码重量
  int get savedCalibrationWeight => _savedCalibrationWeight;

  /// 获取网络状态是否良好
  bool get isNetworkGood => true;

  /// 本地定时任务时间列表（格式："HH:mm"）
  List<String> _localTimerList = [];

  /// 获取定时任务时间列表
  List<String> get timerList => _localTimerList;

  /// 构造函数，监听设备仓库数据更新与应用生命周期
  ActiveDeviceProvider() {
    _repoSubscription = _deviceRepo.onDeviceUpdated.listen((updatedDeviceId) {
      if (_currentDevice != null && _currentDevice!.deviceId == updatedDeviceId) {
        notifyListeners();
      }
    });
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
  }

  /// 资源释放，取消订阅和监听
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _repoSubscription?.cancel();
    super.dispose();
  }

  /// 监听应用生命周期切换（从后台切回前台时自动刷新设备属性）
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

  /// 选择并切换当前操作的设备
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

  /// 设置设备工作模式（自动/定时/手动等）
  Future<void> setMode(WorkMode mode) async {
    if (_currentDevice == null) return;
    if (_currentDevice!.workMode == mode) return;
    if (mode == WorkMode.timer || mode == WorkMode.manual) {
      if (_currentDevice!.isDndEnabled) {
        toggleDnd(false);
      }
    }
    final success = await _deviceRepo.setWorkMode(_currentDevice!.deviceId, mode);
    if (!success) setError("Failed to set mode");
  }

  /// 切换免打扰模式开关
  Future<void> toggleDnd(bool isBool) async {
    if (_currentDevice == null) return;
    final targetState = !_currentDevice!.isDndEnabled;
    final success = await _deviceRepo.setDndStatus(_currentDevice!.deviceId, targetState);
    if (!isBool && (_currentDevice!.workMode != WorkMode.auto)) {
      setMode(WorkMode.auto);
    }
    if (!success) setError("Failed to toggle Do Not Disturb");
  }

  /// 执行设备指定动作（如铲屎、平砂等）
  Future<void> executeAction(ExecuteAction action) async {
    if (_currentDevice == null) return;
    final success = await _deviceRepo.executeAction(_currentDevice!.deviceId, action);
    if (!success) setError("Failed to execute action");
  }

  /// 切换童锁功能开关
  Future<void> toggleChildLock() async {
    if (_currentDevice == null) return;
    final targetState = !_currentDevice!.isChildLockEnabled;
    final success = await _deviceRepo.setChildLock(_currentDevice!.deviceId, targetState);
    if (!success) setError("Failed to toggle child lock");
  }

  /// 更新自动模式下的延迟等待时长
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

  /// 设置免打扰模式的时间段范围
  void setDndTime(String start, String end) async {
    if (_currentDevice == null) return;
    int startSec = _timeToSeconds(start);
    int endSec = _timeToSeconds(end);
    final success = await _deviceRepo.setDndTimeRange(_currentDevice!.deviceId, startSec, endSec);
    if (!success) setError("Failed to set DND time");
  }

  /// 更新本地设置的时区信息
  void setTimeZone(String tzId, String offsetStr) {
    _currentTimeZoneId = tzId;
    _currentTimeZoneOffset = offsetStr;
    notifyListeners();
  }

  /// 在本地定时列表中添加一个新的定时时间
  void addTimer(String timeStr) {
    _localTimerList.add(timeStr);
    _localTimerList.sort();
    notifyListeners();
  }

  /// 从本地定时列表中移除指定索引的定时
  void removeTimer(int index) {
    _localTimerList.removeAt(index);
    notifyListeners();
  }

  /// 提交并保存本地定时任务列表到云端/设备
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

  /// 开始称重校准的第一步（准备校准/去皮）
  Future<bool> startCalibrationStep1() async {
    if (_currentDevice == null) return false;
    setLoading(true);
    final success = await _deviceRepo.startCalibrationStep1(_currentDevice!.deviceId);
    setLoading(false);
    if (!success) setError("Failed");
    return success;
  }

  /// 提交称重校准的第三步（传入参照物重量完成校准）
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

  /// 发送重置 Wi-Fi 指令
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

  /// 发起设备固件升级指令
  Future<bool> startFirmwareUpgrade() async {
    return true;
  }

  /// 更新设备自定义名称
  Future<bool> updateDeviceName(String newName) async {
    if (_currentDevice == null) return false;
    _currentDevice!.deviceName = newName;
    notifyListeners();
    return true;
  }

  /// 显示操作成功的应用 Toast 提示
  void showSuccessToast(String message) {
    NavService.rootNavigatorKey.currentContext?.showAppToast(message: message, type: AppToastType.success);
  }

  /// 将 "HH:mm" 格式的时间字符串转为一天内的总秒数
  int _timeToSeconds(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 3600 + m * 60;
  }

  /// 根据时区名称（如 Asia/Shanghai）计算格式化的时区偏移量字符串
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
