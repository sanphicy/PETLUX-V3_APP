import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petlux/common/constants/dimens.dart';
import 'package:petlux/routes/app_router.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/features/device/device_add/device_add_provider.dart';
import '../models/discovered_device.dart';

class DeviceAddSearchPage extends StatefulWidget {
  const DeviceAddSearchPage({super.key});

  @override
  State<DeviceAddSearchPage> createState() => _DeviceAddSearchPageState();
}

class _DeviceAddSearchPageState extends State<DeviceAddSearchPage> {
  // 品牌统一主金黄色
  static const Color _primaryGold = Color(0xFFF3C746);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceAddProvider>().startSearchDevices();
    });
  }

  void _showSettingsBottomSheet(BuildContext context, DeviceAddProvider provider, S s) {
    bool filterUnknown = provider.filterUnknown;
    bool autoFetchWifi = provider.autoFetchWifi;
    TextEditingController nameCtrl = TextEditingController(text: provider.filterName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20.w, right: 20.w, top: 20.h),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    s.networkSettings,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15.h),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.filterUnknownDevices, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(s.hideUnnamedDevices, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    value: filterUnknown,
                    onChanged: (val) => setState(() => filterUnknown = val),
                    activeColor: _primaryGold,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.autoFetchWifi, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(s.autoFetchWifiDesc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    value: autoFetchWifi,
                    onChanged: (val) => setState(() => autoFetchWifi = val),
                    activeColor: _primaryGold,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    s.exactFilter,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: s.exactFilterHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      backgroundColor: _primaryGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      provider.saveSettings(
                        filterUnknown: filterUnknown,
                        filterName: nameCtrl.text.trim(),
                        autoFetchWifi: autoFetchWifi,
                      );
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      s.saveAndResearch,
                      style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final provider = context.watch<DeviceAddProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF666666)),
            onPressed: () => _showSettingsBottomSheet(context, provider, s),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.searchingLabel,
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: const Color(0xFF333333)),
            ),
            SizedBox(height: Dimens.spacingMini),
            Text(
              s.autoSearching,
              style: TextStyle(
                fontSize: Dimens.fontMedium,
                color: const Color(0xFFB88E14),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 60.h),
            Center(
              child: Icon(Icons.bluetooth_searching, size: 140.w, color: _primaryGold.withValues(alpha: 0.25)),
            ),
            SizedBox(height: 40.h),
            Center(
              child: Text(
                s.noDeviceFoundDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF888888), fontSize: Dimens.fontSmall, height: 1.5),
              ),
            ),
            SizedBox(height: 60.h),
            Row(
              children: [
                Text(
                  s.searchingAvailable,
                  style: TextStyle(fontSize: Dimens.fontMedium, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: Dimens.spacingSmall),
                if (provider.isScanning)
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: _primaryGold),
                  )
                else
                  GestureDetector(
                    onTap: () => provider.startSearchDevices(),
                    child: Icon(Icons.refresh, size: 18.w, color: _primaryGold),
                  ),
              ],
            ),
            SizedBox(height: Dimens.spacingNormal),
            Expanded(
              child: provider.discoveredDevices.isEmpty && !provider.isScanning
                  ? Center(
                      child: TextButton(
                        onPressed: () => provider.startSearchDevices(),
                        child: Text(
                          s.searchAgain,
                          style: const TextStyle(color: _primaryGold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.discoveredDevices.length,
                      separatorBuilder: (_, __) => SizedBox(height: Dimens.spacingNormal),
                      itemBuilder: (context, index) {
                        return _buildDeviceCard(context, s, provider, provider.discoveredDevices[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, S s, DeviceAddProvider provider, DiscoveredDevice device) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimens.spacingNormal, vertical: Dimens.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.radiusNormal),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Dimens.spacingSmall),
            decoration: BoxDecoration(color: _primaryGold.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.devices_other, color: const Color(0xFFB88E14), size: Dimens.iconNormal),
          ),
          SizedBox(width: Dimens.spacingNormal),
          Expanded(
            child: Text(
              device.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimens.fontSmall),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9F9FC),
              foregroundColor: const Color(0xFF222222),
              elevation: 0,
              minimumSize: Size(80.w, 36.h),
              padding: EdgeInsets.symmetric(horizontal: Dimens.spacingNormal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.radiusMax)),
            ),
            onPressed: () {
              context.push(AppRoutes.deviceAddWifi, extra: {'device': device, 'provider': provider});
            },
            child: Text(s.connect, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
