import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/widgets/responsive_layout.dart';
import 'package:petlux/features/device/device_provider.dart';
import 'package:petlux/features/device/device_usage/device_usage_provider.dart';
import 'package:petlux/features/device/models/device_dto.dart';
import 'package:petlux/routes/app_router.dart';

class DeviceUsagePage extends StatefulWidget {
  const DeviceUsagePage({super.key});

  @override
  State<DeviceUsagePage> createState() => _DeviceUsagePageState();
}

class _DeviceUsagePageState extends State<DeviceUsagePage> {
  // 品牌主色对齐金黄色系
  final Color _primaryGold = const Color(0xFFF3C746);
  final Color _bgColor = const Color(0xFFF9F9FC);
  final Color _textColor = const Color(0xFF333333);
  final Color _subTextColor = const Color(0xFF666666);
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = context.read<DeviceProvider>();
      context.read<DeviceUsageProvider>().syncDevices(deviceProvider.devices);
    });
  }

  // 底部弹窗：切换设备清单
  void _showDeviceSwitchSheet(BuildContext context, List<DeviceDto> devices, int currentIndex, S s) {
    final usageVm = context.read<DeviceUsageProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.myDevices,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(AppRoutes.deviceAddSearch); // 👈 原汁原味的路由调用
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 18, color: _primaryGold),
                          const SizedBox(width: 4),
                          Text(
                            s.addDevice,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryGold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final item = devices[index];
                    final isSelected = index == currentIndex;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(item.displayImage, fit: BoxFit.contain),
                      ),
                      title: Text(
                        item.deviceName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? _primaryGold : const Color(0xFF222222),
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: item.isOnline ? const Color(0xFF8CC152) : const Color(0xFFD0D0D4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isOnline ? s.online : s.offline,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      trailing: isSelected ? Icon(Icons.check_rounded, color: _primaryGold, size: 22) : null,
                      onTap: () {
                        usageVm.selectDevice(index);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final deviceProvider = context.watch<DeviceProvider>();
    final usageProvider = context.read<DeviceUsageProvider>();

    if (deviceProvider.devices.length != usageProvider.deviceList.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        usageProvider.syncDevices(deviceProvider.devices);
      });
    }

    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Selector<DeviceUsageProvider, (List<DeviceDto>, int)>(
          selector: (_, vm) => (vm.deviceList, vm.selectedDeviceIndex),
          builder: (context, data, _) {
            final devices = data.$1;
            final selectedIndex = data.$2;
            final currentDevice = devices.isNotEmpty && selectedIndex < devices.length ? devices[selectedIndex] : null;

            final displayName = currentDevice?.deviceName ?? s.tabDevice;

            return GestureDetector(
              onTap: devices.isEmpty ? null : () => _showDeviceSwitchSheet(context, devices, selectedIndex, s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: (currentDevice?.isOnline ?? false) ? const Color(0xFF8CC152) : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        displayName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF666666)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: ResponsiveFormContainer(
          maxWidth: 900,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 7天选择卡片
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Selector<DeviceUsageProvider, (List<DailyUsageData>, int)>(
                    selector: (_, vm) => (vm.weekDays, vm.selectedDayIndex),
                    builder: (context, data, _) {
                      final weekDays = data.$1;
                      final selectedDayIdx = data.$2;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(weekDays.length, (index) {
                          final isSelected = selectedDayIdx == index;
                          final dayData = weekDays[index];
                          return GestureDetector(
                            onTap: () => usageProvider.selectDay(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                              width: 42,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected ? _primaryGold : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 180),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF222222) : _subTextColor,
                                    ),
                                    child: Text(dayData.getWeekdayName(s)),
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 180),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected ? const Color(0xFF222222) : _textColor,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                    child: Text(dayData.dayStr),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 2. 核心统计指标卡片
                Selector<DeviceUsageProvider, DailyUsageData?>(
                  selector: (_, vm) => vm.selectedDayData,
                  builder: (context, selectedData, _) {
                    return Row(
                      children: [
                        _buildStatCard(s.toiletTimes, '${selectedData?.times ?? 0}', s.timesUnit, Icons.pets_rounded),
                        const SizedBox(width: 15),
                        _buildStatCard(
                          s.toiletDuration,
                          '${selectedData?.duration ?? 0}',
                          s.secondsUnit,
                          Icons.timer_outlined,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),

                // 3. 趋势图表区
                if (isLargeScreen)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildChartSection(
                          title: s.timesTrend,
                          chart: Selector<DeviceUsageProvider, List<DailyUsageData>>(
                            selector: (_, vm) => vm.weekDays,
                            builder: (context, weekDays, _) => _buildLineChart(weekDays, isTimes: true, s: s),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildChartSection(
                          title: s.durationTrend,
                          chart: Selector<DeviceUsageProvider, List<DailyUsageData>>(
                            selector: (_, vm) => vm.weekDays,
                            builder: (context, weekDays, _) => _buildLineChart(weekDays, isTimes: false, s: s),
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildChartSection(
                    title: s.timesTrend,
                    chart: Selector<DeviceUsageProvider, List<DailyUsageData>>(
                      selector: (_, vm) => vm.weekDays,
                      builder: (context, weekDays, _) => _buildLineChart(weekDays, isTimes: true, s: s),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildChartSection(
                    title: s.durationTrend,
                    chart: Selector<DeviceUsageProvider, List<DailyUsageData>>(
                      selector: (_, vm) => vm.weekDays,
                      builder: (context, weekDays, _) => _buildLineChart(weekDays, isTimes: false, s: s),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection({required String title, required Widget chart}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, color: _textColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 210,
          padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: chart,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: _subTextColor, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _primaryGold.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: _primaryGold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor, height: 1),
                ),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 12, color: _subTextColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<DailyUsageData> weekDays, {required bool isTimes, required S s}) {
    final List<FlSpot> spots = weekDays.asMap().entries.map((e) {
      final val = isTimes ? e.value.times : e.value.duration;
      return FlSpot(e.key.toDouble(), val.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0EFF5), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx >= 0 && idx < weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(weekDays[idx].getWeekdayName(s), style: TextStyle(fontSize: 11, color: _subTextColor)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.toInt()}${isTimes ? s.timesUnit : s.secondsUnit}',
                  style: TextStyle(fontSize: 10, color: _subTextColor),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(bottom: BorderSide(color: Color(0xFFE5E5EE), width: 1)),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: _primaryGold,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2.5, strokeColor: _primaryGold),
            ),
            belowBarData: BarAreaData(show: true, color: _primaryGold.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}
