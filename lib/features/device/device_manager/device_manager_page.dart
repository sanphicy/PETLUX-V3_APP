import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:v3/features/device/active_device_provider.dart';
import 'package:v3/features/device/models/device_thing_model.dart';

class DeviceManagerPage extends StatelessWidget {
  final String deviceId;
  const DeviceManagerPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveDeviceProvider>();
    final device = provider.currentDevice;
    if (device == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEBEBEB),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFDBAB3F))),
      );
    }
    const Color bgColor = Color(0xFFEBEBEB);
    const Color primaryYellow = Color(0xFFDBAB3F);
    const Color textColor = Color(0xFF333333);
    const Color pillGray = Color(0xFFE8E8E8);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double safeBodyHeight = screenHeight - statusBarHeight - appBarHeight;
    final bool isLocked = provider.isLoading || device.isOperating;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              device.deviceName,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('ID: ${device.deviceId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
            onPressed: () {
              context.push('/device_setting/$deviceId');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: primaryYellow, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('  Today', style: TextStyle(fontSize: 16, color: textColor)),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                device.todayTimes,
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  height: 1,
                                ),
                              ),
                              const Text('Times', style: TextStyle(fontSize: 14, color: textColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('  Average', style: TextStyle(fontSize: 16, color: textColor)),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                device.averageSeconds,
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                  height: 1,
                                ),
                              ),
                              const Text('S', style: TextStyle(fontSize: 16, color: textColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/device-logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.devices, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Text(
              device.executeAction.label,
              style: const TextStyle(color: primaryYellow, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              height: safeBodyHeight,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildModePill(
                        title: 'Auto\nmode',
                        icon: Icons.autorenew,
                        isActive: device.workMode == WorkMode.auto,
                        activeColor: primaryYellow,
                        inactiveColor: pillGray,
                        onTap: () => provider.setMode(WorkMode.auto),
                      ),
                      _buildModePill(
                        title: 'Do not\ndisturb',
                        icon: Icons.nightlight_round,
                        isActive: device.isDndEnabled,
                        activeColor: primaryYellow,
                        inactiveColor: pillGray,
                        onTap: () => provider.toggleDnd(false),
                      ),
                      _buildModePill(
                        title: 'Timing\nmode',
                        icon: Icons.timer,
                        isActive: device.workMode == WorkMode.timer,
                        activeColor: primaryYellow,
                        inactiveColor: pillGray,
                        onTap: () => provider.setMode(WorkMode.timer),
                      ),
                      _buildModePill(
                        title: 'Manual\nmode',
                        icon: Icons.touch_app,
                        isActive: device.workMode == WorkMode.manual,
                        activeColor: primaryYellow,
                        inactiveColor: pillGray,
                        onTap: () => provider.setMode(WorkMode.manual),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(color: primaryYellow, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          context,
                          'Clean',
                          Icons.cleaning_services,
                          isLocked ? null : () => provider.executeAction(ExecuteAction.cleaning),
                          isLocked: isLocked,
                        ),
                        _buildActionButton(
                          context,
                          'Smooth',
                          Icons.blur_on,
                          isLocked ? null : () => provider.executeAction(ExecuteAction.smoothing),
                          isLocked: isLocked,
                        ),
                        _buildActionButton(
                          context,
                          'Child Lock',
                          device.isChildLockEnabled ? Icons.lock : Icons.lock_outline,
                          provider.isLoading ? null : () => provider.toggleChildLock(),
                          isLocked: provider.isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Device record today',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: device.logs.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final log = device.logs[index];
                                final timeStr =
                                    "${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}";
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Text(
                                    '  $timeStr ${log.content}',
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModePill({
    required String title,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 140,
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(6),
              height: 63,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: isActive ? activeColor : Colors.grey, size: 30)),
            ),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF666666),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap, {
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFDBAB3F), size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
