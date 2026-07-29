import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:v3/features/device/device_provider.dart';
import 'package:v3/features/device/device_list/device_card.dart';
import 'package:v3/routes/app_router.dart';
import 'package:v3/common/widgets/app_avatar.dart';
import 'package:v3/features/user/user_provider.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final userProider = context.watch<UserProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    final double topImageHeight = screenWidth * 0.32;

    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      body: Stack(
        children: [
          Positioned(
            top: topImageHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: provider.isLoading && provider.devices.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchDevices(),
                      color: const Color(0xFFF3D14B),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
                        itemCount: provider.devices.length,
                        itemBuilder: (context, index) {
                          final device = provider.devices[index];
                          return DeviceCard(
                            deviceName: device.deviceName,
                            deviceId: device.deviceId,
                            isOnline: device.isOnline,
                            imageUrl: 'assets/images/device-logo.png',
                            onTap: () {
                              context.push('/device_manager/${device.deviceId}');
                            },
                            onDelete: () async {
                              await context.read<DeviceProvider>().deleteDevice(device.deviceId);
                              context.read<DeviceProvider>().fetchDevices();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ),
          // 顶部背景图
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/petlux-top_bg.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          Positioned(
            top: topImageHeight,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF3D14B), borderRadius: BorderRadius.circular(40)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAvatar(avatarUrl: userProider.avatarUrl, radius: 25),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          userProider.userName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                        ),
                        Text('Device online', style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top - 10,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
              onPressed: () {
                context.push(AppRoutes.deviceAddSearch);
              },
            ),
          ),
        ],
      ),
    );
  }
}
