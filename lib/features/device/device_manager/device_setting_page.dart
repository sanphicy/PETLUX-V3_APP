import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:v3/features/device/active_device_provider.dart';
import 'package:v3/common/widgets/app_wheel_picker_sheet.dart';
import 'package:v3/common/widgets/app_dialogs.dart';

class DeviceSettingPage extends StatelessWidget {
  final String deviceId;
  const DeviceSettingPage({super.key, required this.deviceId});

  Future<void> _pickDndTime(BuildContext context, ActiveDeviceProvider provider) async {
    final start = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'Start Time');
    if (start == null || !context.mounted) return;
    final end = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'End Time');
    if (end == null) return;
    provider.setDndTime(
      "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
      "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
    );
  }

  void _showOtaDialog(BuildContext context, ActiveDeviceProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Firmware Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text(
            'A new firmware version (${provider.newFirmwareVersion}) is available. Do you want to update now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await provider.startFirmwareUpgrade();
                if (success && context.mounted) {
                  context.showAppToast(message: "Update command sent successfully", type: AppToastType.success);
                }
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Color(0xFFDBAB3F), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveDeviceProvider>();
    final device = provider.currentDevice;

    if (device == null) {
      return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: const Color(0xFFF6F6F6)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    const Color bgColor = Color(0xFFF6F6F6);
    const Color textColor = Color(0xFF333333);
    const Color offlineColor = Color(0xFFF39191);
    const Color onlineColor = Color(0xFF8CC152);

    final dndRange = device.dndTimeRange;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Setting',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: provider.isLoading && device.firmwareVersion.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDBAB3F)))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/device-logo.png',
                        width: 70,
                        height: 70,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.devices, size: 70, color: Colors.grey),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  device.deviceName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                                ),
                                GestureDetector(
                                  onTap: () => _showEditNameDialog(context, provider),
                                  child: Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              device.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 13,
                                color: device.isOnline ? onlineColor : offlineColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Firmware version: ${device.firmwareVersion}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            const Text('Equipment serialnumber', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(deviceId, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardGroup(
                  children: [
                    _buildSettingTile(
                      Icons.public,
                      'Time zone',
                      trailingText: provider.currentTimeZoneOffset,
                      onTap: () => context.push('/device_setting/$deviceId/timezone'),
                    ),
                  ],
                ),
                _buildSectionTitle('Mode settings'),
                _buildCardGroup(
                  children: [
                    _buildSettingTile(
                      Icons.autorenew,
                      'Auto mode',
                      showDivider: true,
                      trailingText: '${provider.autoModeOptions[provider.autoModeIndex]} mins',
                      onTap: () {
                        AppWheelPickerSheet.show(
                          context,
                          title: 'Auto mode',
                          items: provider.autoModeOptions.map((e) => '$e mins').toList(),
                          initialIndex: provider.autoModeIndex,
                          onConfirm: (int index) => provider.updateAutoMode(index),
                        );
                      },
                    ),
                    _buildSettingTile(
                      Icons.nightlight_round,
                      'Do not disturb',
                      showDivider: true,
                      trailingText: '${dndRange['start']} - ${dndRange['end']}',
                      onTap: () => _pickDndTime(context, provider),
                    ),
                    _buildSettingTile(
                      Icons.timer,
                      'Timing mode',
                      onTap: () => context.push('/device_setting/$deviceId/timer'),
                    ),
                  ],
                ),
                _buildSectionTitle('Other settings'),
                _buildCardGroup(
                  children: [
                    _buildSettingTile(
                      Icons.system_update_alt,
                      'Firmware Upgrade',
                      showDivider: true,
                      trailingText: device.firmwareVersion,
                      showRedDot: provider.hasNewFirmware,
                      onTap: provider.hasNewFirmware ? () => _showOtaDialog(context, provider) : null,
                    ),
                    _buildSettingTile(
                      Icons.wifi,
                      'Wifi Info',
                      showDivider: true,
                      onTap: () => context.push('/device_setting/$deviceId/wifi'),
                    ),
                    _buildSettingTile(
                      Icons.monitor_weight_outlined,
                      'Weighing verification',
                      showDivider: true,
                      onTap: () => context.push('/device_setting/$deviceId/weighing'),
                    ),
                    _buildSettingTile(
                      Icons.help_outline,
                      'help',
                      onTap: () async {
                        final Uri url = Uri.parse('https://jooyopet.com/support');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          debugPrint('Error launching URL');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  void _showEditNameDialog(BuildContext context, ActiveDeviceProvider provider) {
    final TextEditingController controller = TextEditingController(text: provider.currentDevice?.deviceName ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Edit Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter custom name',
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFDBAB3F))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final newName = controller.text.trim();
                Navigator.pop(ctx);
                if (newName.isNotEmpty) {
                  await provider.updateDeviceName(newName);
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Color(0xFFDBAB3F), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 25, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title, {
    bool showDivider = false,
    String? trailingText,
    bool showRedDot = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey.shade600, size: 22),
          title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null) Text(trailingText, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              if (showRedDot) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ],
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, thickness: 0.5, indent: 50, endIndent: 16, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
