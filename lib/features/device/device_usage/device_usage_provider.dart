import 'package:flutter/material.dart';
import 'package:v3/common/providers/base_provider.dart';

class DeviceUsageProvider extends BaseProvider {
  // --- 状态数据 ---
  int _selectedDeviceIndex = 0;
  int _selectedDayIndex = 6; // 默认选中最后一天 (MON 13)
  int _selectedTimeRangeIndex = 0; // 默认选中 1 month

  // --- 模拟静态配置 ---
  final List<String> _devices = ['Device-A', 'Device-B'];
  // 日历模拟数据 (实际开发中应动态生成日期)
  final List<Map<String, String>> _weekDays = [
    {'week': 'TUE', 'day': '7'},
    {'week': 'WED', 'day': '8'},
    {'week': 'THU', 'day': '9'},
    {'week': 'FRI', 'day': '10'},
    {'week': 'SAT', 'day': '11'},
    {'week': 'SUN', 'day': '12'},
    {'week': 'MON', 'day': '13'},
  ];
  final List<String> _timeRanges = ['1 month', '3 months', '6 months', '9 months'];

  // --- 模拟统计数据 ---
  String _todayTimes = '0';
  String _averageSeconds = '0';
  String _currentWeigh = '0.0';

  // --- Getters ---
  int get selectedDeviceIndex => _selectedDeviceIndex;
  int get selectedDayIndex => _selectedDayIndex;
  int get selectedTimeRangeIndex => _selectedTimeRangeIndex;
  List<String> get devices => _devices;
  List<Map<String, String>> get weekDays => _weekDays;
  List<String> get timeRanges => _timeRanges;
  String get todayTimes => _todayTimes;
  String get averageSeconds => _averageSeconds;
  String get currentWeigh => _currentWeigh;

  // 获取当前选中设备的名称
  String get currentDeviceName => _devices.isNotEmpty ? _devices[_selectedDeviceIndex] : '';

  // 切换设备
  void selectDevice(int index) {
    if (_selectedDeviceIndex == index) return;
    _selectedDeviceIndex = index;
    _fetchDataForSelection();
  }

  // 切换日期
  void selectDay(int index) {
    if (_selectedDayIndex == index) return;
    _selectedDayIndex = index;
    _fetchDataForSelection();
  }

  // 切换折线图时间范围
  void selectTimeRange(int index) {
    if (_selectedTimeRangeIndex == index) return;
    _selectedTimeRangeIndex = index;
    notifyListeners();
    // TODO: 重新请求图表数据
  }

  // 模拟网络请求刷新数据
  void _fetchDataForSelection() {
    setLoading(true);
    // 模拟接口延迟
    Future.delayed(const Duration(milliseconds: 300), () {
      // 随机生成一些假数据模拟切换效果
      _todayTimes = (_selectedDeviceIndex * 2 + _selectedDayIndex).toString();
      _averageSeconds = (_selectedDayIndex * 15).toString();
      _currentWeigh = (4.5 + _selectedDeviceIndex).toStringAsFixed(1);
      setLoading(false);
      notifyListeners();
    });
  }
}
