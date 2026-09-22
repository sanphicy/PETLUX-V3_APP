import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:petlux/routes/app_router.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/widgets/responsive_layout.dart';
import 'package:petlux/features/device/active_device_provider.dart';
import 'package:petlux/features/device/models/device_dto.dart';
import 'package:petlux/features/device/models/device_thing_model.dart';

class DeviceManagerPage extends StatelessWidget {
  final String deviceId;
  const DeviceManagerPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final provider = context.read<ActiveDeviceProvider>();

    // 品牌统一主金色
    const Color primaryGold = Color(0xFFF3C746);
    const Color darkGoldText = Color(0xFF222222);
    const Color bgColor = Color(0xFFF9F9FC);
    const Color textColor = Color(0xFF333333);
    const Color pillGray = Color(0xFFF0EFF5);
    String _formatTimesUnit(int count, S s) {
      if (s.timesUnit == '次') return s.timesUnit;
      return count == 1 ? 'time' : 'times';
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Selector<ActiveDeviceProvider, (String, String)>(
          selector: (_, vm) => (vm.currentDevice?.deviceName ?? '', vm.currentDevice?.displayId ?? ''),
          builder: (context, data, _) {
            return Column(
              children: [
                Text(
                  data.$1.isNotEmpty ? data.$1 : 'petlux',
                  style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('ID: ${data.$2}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: primaryGold),
            onPressed: () => context.push('/device_setting/$deviceId'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveFormContainer(
          maxWidth: 600,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 1. 今日如厕与平均时长卡片
                Selector<ActiveDeviceProvider, (String, String)>(
                  selector: (_, vm) => (vm.currentDevice?.todayTimes ?? '0', vm.currentDevice?.averageSeconds ?? '0'),
                  builder: (context, stats, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryGold,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGold.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.todayToilet,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: darkGoldText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stats.$1,
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: darkGoldText,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      _formatTimesUnit(int.tryParse(stats.$1) ?? 0, s),
                                      style: const TextStyle(fontSize: 14, color: darkGoldText),
                                    ),
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
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.averageDuration, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stats.$2,
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        height: 1,
                                      ),
                                    ),
                                    Text(s.secondsUnit, style: const TextStyle(fontSize: 14, color: textColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 2. 设备图与状态标签
                Image.asset(
                  provider.currentDevice?.displayImage ?? 'assets/images/product-pic.png',
                  width: 110,
                  height: 110,
                  errorBuilder: (_, __, ___) => const Icon(Icons.devices, size: 90, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Selector<ActiveDeviceProvider, (ExecuteAction, bool)>(
                  selector: (_, vm) =>
                      (vm.currentDevice?.executeAction ?? ExecuteAction.idle, vm.currentDevice?.isOnline ?? false),
                  builder: (context, data, _) {
                    final action = data.$1;
                    final isOnline = data.$2;
                    final statusText = isOnline ? action.getLocalizedLabel(s) : s.offline;
                    final tagBgColor = isOnline
                        ? primaryGold.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15);
                    final tagTextColor = isOnline ? const Color(0xFFB88E14) : Colors.grey.shade600;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(color: tagBgColor, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        statusText,
                        style: TextStyle(color: tagTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 3. 操作控制面板
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 模式胶囊按钮
                      Selector<ActiveDeviceProvider, (WorkMode, bool)>(
                        selector: (_, vm) =>
                            (vm.currentDevice?.workMode ?? WorkMode.auto, vm.currentDevice?.isDndEnabled ?? false),
                        builder: (context, state, _) {
                          final workMode = state.$1;
                          final isDnd = state.$2;
                          return Row(
                            children: [
                              _buildModePill(
                                title: s.autoMode,
                                icon: Icons.autorenew_rounded,
                                isActive: workMode == WorkMode.auto,
                                activeColor: primaryGold,
                                inactiveColor: pillGray,
                                onTap: () => provider.setMode(WorkMode.auto),
                              ),
                              const SizedBox(width: 8),
                              _buildModePill(
                                title: s.dndMode,
                                icon: Icons.nightlight_round,
                                isActive: isDnd,
                                activeColor: primaryGold,
                                inactiveColor: pillGray,
                                onTap: () => provider.toggleDnd(false),
                              ),
                              const SizedBox(width: 8),
                              _buildModePill(
                                title: s.timerMode,
                                icon: Icons.timer_rounded,
                                isActive: workMode == WorkMode.timer,
                                activeColor: primaryGold,
                                inactiveColor: pillGray,
                                onTap: () => provider.setMode(WorkMode.timer),
                              ),
                              const SizedBox(width: 8),
                              _buildModePill(
                                title: s.manualMode,
                                icon: Icons.touch_app_rounded,
                                isActive: workMode == WorkMode.manual,
                                activeColor: primaryGold,
                                inactiveColor: pillGray,
                                onTap: () => provider.setMode(WorkMode.manual),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 动作执行卡片区
                      // 动作执行卡片区
                      Selector<ActiveDeviceProvider, (bool, bool, bool, bool, bool)>(
                        selector: (_, vm) => (
                          vm.isLoading,
                          vm.currentDevice?.isOperating ?? false,
                          vm.currentDevice?.isPlasmaEnabled ?? false,
                          vm.currentDevice?.isChildLockEnabled ?? false,
                          vm.canShowPlasma,
                        ),
                        builder: (context, state, _) {
                          final isBusy = state.$1 || state.$2;
                          final isPlasma = state.$3;
                          final isLock = state.$4;
                          final canShowPlasma = state.$5;

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: primaryGold,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGold.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  s.actionClean,
                                  Icons.cleaning_services_rounded,
                                  isBusy ? null : () => provider.executeAction(ExecuteAction.cleaning),
                                  isLocked: isBusy,
                                  iconColor: primaryGold,
                                ),
                                _buildActionButton(
                                  s.actionSmooth,
                                  Icons.blur_on_rounded,
                                  isBusy ? null : () => provider.executeAction(ExecuteAction.smoothing),
                                  isLocked: isBusy,
                                  iconColor: primaryGold,
                                ),
                                if (canShowPlasma)
                                  _buildActionButton(
                                    s.actionDeodorize,
                                    isPlasma ? Icons.bubble_chart_rounded : Icons.bubble_chart_outlined,
                                    state.$1 ? null : () => provider.togglePlasma(),
                                    isLocked: state.$1,
                                    iconColor: primaryGold,
                                  ),
                                _buildActionButton(
                                  s.actionChildLock,
                                  isLock ? Icons.lock_rounded : Icons.lock_open_rounded,
                                  state.$1 ? null : () => provider.toggleChildLock(),
                                  isLocked: state.$1,
                                  iconColor: primaryGold,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 今日日志列表
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 180),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.todayLogs,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 12),
                            Selector<ActiveDeviceProvider, List<DeviceLog>>(
                              selector: (_, vm) => List<DeviceLog>.from(vm.currentDevice?.logs ?? []),
                              builder: (context, logs, _) {
                                if (logs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(s.noLogs, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    final log = logs[index];
                                    final timeStr =
                                        "${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}";
                                    String parsedContent = '';
                                    if (log.isAction) {
                                      try {
                                        final action = ExecuteAction.values.byName(log.content);
                                        parsedContent = action.getLocalizedLabel(s);
                                      } catch (_) {
                                        parsedContent = log.content;
                                      }
                                    } else {
                                      final seconds = int.tryParse(log.content) ?? log.content;
                                      parsedContent = s.catToiletLog(seconds);
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(color: primaryGold, shape: BoxShape.circle),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$timeStr  $parsedContent',
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 120,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                height: 50,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(child: Icon(icon, color: isActive ? const Color(0xFFB88E14) : Colors.grey, size: 24)),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? const Color(0xFF222222) : const Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback? onTap, {
    bool isLocked = false,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFB88E14), size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF222222), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
