import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // 引入刚才添加的图表库
import 'package:v3/features/device/device_usage/device_usage_provider.dart';

class DeviceUsagePage extends StatelessWidget {
  const DeviceUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceUsageProvider>();
    const Color bgColor = Color(0xFFF9F8FC); // 极浅的紫灰色背景
    const Color textColor = Color(0xFF333333);
    const Color cardColor = Color(0xFFEBEBEB); // 卡片灰色

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: textColor, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==============================
            // 1. 顶部设备选择列表
            // ==============================
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...List.generate(provider.devices.length, (index) {
                    final isSelected = provider.selectedDeviceIndex == index;
                    return GestureDetector(
                      onTap: () => provider.selectDevice(index),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? textColor : Colors.transparent, width: 1.5),
                                // 占位图，实际可替换为设备缩略图
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(provider.devices[index], style: const TextStyle(fontSize: 12, color: textColor)),
                          ],
                        ),
                      ),
                    );
                  }),
                  // 添加设备按钮
                  GestureDetector(
                    onTap: () {},
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
                        const Text('Add', style: TextStyle(fontSize: 12, color: textColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ==============================
            // 2. 当前选中设备名称
            // ==============================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      provider.currentDeviceName,
                      style: const TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.w500),
                    ),
                    const Text('Online', style: TextStyle(fontSize: 14, color: Color(0xFF5B71A6))), // 在线状态
                  ],
                ),
                const SizedBox(width: 10),
                Icon(Icons.edit, color: Colors.grey.shade500, size: 20),
              ],
            ),
            const SizedBox(height: 25),

            // ==============================
            // 3. 星期/日期选择器
            // ==============================
            Container(
              height: 65,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(provider.weekDays.length, (index) {
                  final isSelected = provider.selectedDayIndex == index;
                  final dayData = provider.weekDays[index];
                  return GestureDetector(
                    onTap: () => provider.selectDay(index),
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
                          Text(dayData['week']!, style: const TextStyle(fontSize: 12, color: textColor)),
                          const SizedBox(height: 2),
                          Text(
                            dayData['day']!,
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
            // 4. 数据统计卡片
            // ==============================
            Row(
              children: [
                _buildStatCard('Today', provider.todayTimes, 'Times'),
                const SizedBox(width: 15),
                _buildStatCard('Average', provider.averageSeconds, 'S'),
                const SizedBox(width: 15),
                _buildStatCard('Weigh', provider.currentWeigh, '/KG', highlightValue: true),
              ],
            ),
            const SizedBox(height: 30),

            // 5. Weight Curve 折线图
            const Text(
              'Weight curve',
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),

            // 时间维度切换器
            Container(
              height: 35,
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: List.generate(provider.timeRanges.length, (index) {
                  final isSelected = provider.selectedTimeRangeIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.selectTimeRange(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD6D5D8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          provider.timeRanges[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? textColor : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // 图表组件
            SizedBox(height: 200, child: _buildLineChart()),
            const SizedBox(height: 30),

            // ==============================
            // 6. Times Curve 折线图
            // ==============================
            const Text(
              'Times curve',
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: _buildLineChart(isTimes: true), // 复用图表组件，传入参数区分
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 统计卡片小组件
  Widget _buildStatCard(String title, String value, String unit, {bool highlightValue = false}) {
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
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: highlightValue ? const Color(0xFF333333) : const Color(0xFF333333),
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

  // 基于 fl_chart 构建折线图
  Widget _buildLineChart({bool isTimes = false}) {
    final lineColor = const Color(0xFF5B71A6); // 截图中的深蓝色线条

    // 模拟数据点
    final List<FlSpot> spots = isTimes
        ? const [FlSpot(1, 20), FlSpot(3, 15), FlSpot(5, 25), FlSpot(7, 10)] // Times 图模拟数据
        : const [
            FlSpot(0, 4),
            FlSpot(1, 3),
            FlSpot(2, 10),
            FlSpot(3, 9),
            FlSpot(3.5, 7),
            FlSpot(4, 12),
            FlSpot(5, 10),
            FlSpot(9, 10),
            FlSpot(13, 15),
            FlSpot(18, 20),
          ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
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
              interval: 3,
              getTitlesWidget: (value, meta) {
                if (value == 2) return const Text('294月', style: TextStyle(fontSize: 10, color: Colors.grey));
                if (value == 5) return const Text('8', style: TextStyle(fontSize: 10, color: Colors.grey));
                if (value == 8) return const Text('15', style: TextStyle(fontSize: 10, color: Colors.grey));
                if (value == 11) return const Text('22', style: TextStyle(fontSize: 10, color: Colors.grey));
                if (value == 14) return const Text('255月', style: TextStyle(fontSize: 10, color: Colors.grey));
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} ${isTimes ? '' : 'kg'}',
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
        maxX: 19,
        minY: 0,
        maxY: 25,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false, // 截图中是折线而非平滑曲线
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 2, strokeColor: lineColor),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
