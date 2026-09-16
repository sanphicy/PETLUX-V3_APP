import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/providers/user_provider.dart';
import 'package:petlux/common/widgets/app_avatar.dart';
import 'package:petlux/common/widgets/responsive_layout.dart';
import 'package:petlux/features/device/device_list/device_card.dart';
import 'package:petlux/features/device/device_provider.dart';
import 'package:petlux/features/device/models/device_dto.dart';
import 'package:petlux/routes/app_router.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  static const Color _pillYellow = Color(0xFFF3C746);
  static const Color _loadingGrey = Color(0xFF555555);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().fetchDevices();
      context.read<UserProvider>().fetchUserInfo(isSilent: true);
    });
  }

  void _showRenameDialog(BuildContext context, String deviceId, String currentName, S s) {
    final TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(s.renameDevice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _pillYellow)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final newName = controller.text.trim();
                Navigator.pop(ctx);
                if (newName.isNotEmpty && newName != currentName) {
                  await context.read<DeviceProvider>().renameDevice(deviceId, newName);
                }
              },
              child: Text(
                s.confirm,
                style: const TextStyle(color: _pillYellow, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String deviceId, String deviceName, S s) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(s.deleteDevice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text(
            s.deleteDeviceConfirm(deviceName),
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await context.read<DeviceProvider>().deleteDevice(deviceId);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.deleteSuccess)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.deleteFailed)));
                }
              },
              child: Text(
                s.delete,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final deviceProvider = context.read<DeviceProvider>();
    final mediaQuery = MediaQuery.of(context);

    final screenWidth = mediaQuery.size.width;
    final statusBarHeight = mediaQuery.padding.top;

    const double headerAspectRatio = 2.15;
    final double headerImgHeight = screenWidth / headerAspectRatio;
    final double totalHeaderHeight = statusBarHeight + headerImgHeight;
    final double cutOffTop = statusBarHeight + (headerImgHeight * 0.92);
    final double pillCenterTop = statusBarHeight + (headerImgHeight * 0.78) - 22;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 第一层：设备卡片列表
          Positioned(
            top: cutOffTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: ResponsiveFormContainer(
                maxWidth: 600,
                child: RefreshIndicator(
                  color: _loadingGrey, // 👈 下拉刷新换成通用深灰
                  backgroundColor: Colors.white,
                  strokeWidth: 2.2,
                  onRefresh: () async {
                    await deviceProvider.fetchDevices();
                  },
                  child: Selector<DeviceProvider, (bool, List<DeviceDto>)>(
                    selector: (_, devVm) => (devVm.isLoading, devVm.devices),
                    builder: (context, data, _) {
                      final isLoading = data.$1;
                      final devices = List<DeviceDto>.from(data.$2)
                        ..sort((a, b) => (b.isOnline ? 1 : 0).compareTo(a.isOnline ? 1 : 0));

                      if (isLoading && devices.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _loadingGrey, // 👈 全屏等待换成通用深灰
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      if (devices.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          children: [
                            SizedBox(height: mediaQuery.size.height * 0.15),
                            Center(
                              child: Text(s.noLogs, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return DeviceCard(
                            deviceName: device.deviceName,
                            deviceId: device.displayId,
                            isOnline: device.isOnline,
                            imageUrl: device.displayImage,
                            onTap: () => context.push('/device_manager/${device.deviceId}'),
                            onRename: () => _showRenameDialog(context, device.deviceId, device.deviceName, s),
                            onDelete: () => _showDeleteConfirmDialog(context, device.deviceId, device.deviceName, s),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 第二层：Header 区域
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: totalHeaderHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: statusBarHeight + 10,
                  child: Container(color: const Color(0xFF262626)),
                ),
                Positioned(
                  top: statusBarHeight,
                  left: 0,
                  right: 0,
                  height: headerImgHeight,
                  child: Image.asset(
                    'assets/images/device_list_header.png',
                    width: screenWidth,
                    height: headerImgHeight,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: statusBarHeight + 4,
                  right: 14,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: Colors.white),
                    onPressed: () => context.push(AppRoutes.deviceAddSearch),
                  ),
                ),
                Positioned(
                  top: pillCenterTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Selector<UserProvider, (String, String)>(
                      selector: (_, userVm) => (userVm.user.avatarUrl, userVm.user.nickname),
                      builder: (context, userData, _) {
                        final avatarUrl = userData.$1;
                        final rawName = userData.$2.trim();
                        final userName = (rawName.isNotEmpty && rawName != 'Unknown User') ? rawName : 'user_';

                        return Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _pillYellow,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppAvatar(avatarUrl: avatarUrl, radius: 17),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 130),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF222222),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Selector<DeviceProvider, int>(
                                      selector: (_, devVm) => devVm.devices.where((d) => d.isOnline).length,
                                      builder: (context, onlineCount, _) {
                                        return Text(
                                          '${s.online}: $onlineCount',
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            color: Color(0xFF555555),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
