import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:v3/features/device/device_provider.dart';
import 'package:v3/features/device/device_usage/device_usage_provider.dart';
import 'package:v3/routes/app_router.dart';

class DeviceUsagePage extends StatefulWidget {
  const DeviceUsagePage({super.key});

  @override
  State<DeviceUsagePage> createState() => _DeviceUsagePageState();
}

class _DeviceUsagePageState extends State<DeviceUsagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProvider = context.read<DeviceProvider>();
      context.read<DeviceUsageProvider>().syncDevices(deviceProvider.devices);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final usageProvider = context.watch<DeviceUsageProvider>();

    if (deviceProvider.devices.length != usageProvider.deviceList.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        usageProvider.syncDevices(deviceProvider.devices);
      });
    }

    const Color bgColor = Color(0xFFF9F8FC);
    const Color textColor = Color(0xFF333333);
    const Color cardColor = Color(0xFFEBEBEB);

    final selectedData = usageProvider.selectedDayData;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '使用统计',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: usageProvider.isLoading && usageProvider.weekDays.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF3D14B)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==============================
                  // 1. 横向滚动设备列表
                  // ==============================
                  Container(
                    height: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: usageProvider.deviceList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == usageProvider.deviceList.length) {
                          return GestureDetector(
                            onTap: () => context.push(AppRoutes.deviceAddSearch),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: textColor, width: 1),
                                      color: Colors.transparent,
                                    ),
                                    child: const Icon(Icons.add, color: textColor),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text('添加', style: TextStyle(fontSize: 12, color: textColor)),
                                ],
                              ),
                            ),
                          );
                        }

                        final isSelected = usageProvider.selectedDeviceIndex == index;
                        final device = usageProvider.deviceList[index];

                        return GestureDetector(
                          onTap: () => usageProvider.selectDevice(index),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF8CC152) : Colors.transparent,
                                      width: 2,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Image.asset('assets/images/device-logo.png', fit: BoxFit.contain),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  device.deviceName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? const Color(0xFFDBAB3F) : textColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==============================
                  // 2. 近7天日期选择
                  // ==============================
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(usageProvider.weekDays.length, (index) {
                        final isSelected = usageProvider.selectedDayIndex == index;
                        final dayData = usageProvider.weekDays[index];

                        return GestureDetector(
                          onTap: () => usageProvider.selectDay(index),
                          child: Container(
                            width: 45,
                            height: 65,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE2DFE4) : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(dayData.weekDay, style: const TextStyle(fontSize: 12, color: textColor)),
                                const SizedBox(height: 2),
                                Text(
                                  dayData.dayStr,
                                  style: const TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================
                  // 3. 数据统计卡片
                  // ==============================
                  Row(
                    children: [
                      _buildStatCard('排泄次数', '${selectedData?.times ?? 0}', '次'),
                      const SizedBox(width: 15),
                      _buildStatCard('排泄时长', '${selectedData?.duration ?? 0}', '秒'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ==============================
                  // 4. 排泄次数折线图
                  // ==============================
                  const Text(
                    '排泄次数曲线 (近7天)',
                    style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(height: 200, child: _buildLineChart(usageProvider, isTimes: true)),

                  const SizedBox(height: 30),

                  // ==============================
                  // 5. 排泄时长折线图
                  // ==============================
                  const Text(
                    '排泄时长曲线 (近7天)',
                    style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(height: 200, child: _buildLineChart(usageProvider, isTimes: false)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(color: const Color(0xFFF0EFF2), borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 恢复到原版样式的统一 LineChart 方法
  Widget _buildLineChart(DeviceUsageProvider provider, {bool isTimes = false}) {
    final lineColor = const Color(0xFF5B71A6);

    final List<FlSpot> spots = provider.weekDays.asMap().entries.map((e) {
      final val = isTimes ? e.value.times : e.value.duration;
      return FlSpot(e.key.toDouble(), val.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (idx >= 0 && idx < provider.weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      provider.weekDays[idx].weekDay,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}${isTimes ? '次' : '秒'}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false, // 恢复为直线样式
            color: lineColor,
            barWidth: 2, // 恢复为细线
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3, // 恢复原版大小
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: lineColor,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
