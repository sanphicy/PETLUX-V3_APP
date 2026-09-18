import 'package:flutter/material.dart';
import 'package:petlux/app.dart';
import 'package:petlux/features/user/viewmodels/user_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:petlux/common/config/app_constants.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/widgets/app_avatar.dart';
import 'package:petlux/common/widgets/responsive_layout.dart';
import 'package:petlux/common/providers/user_provider.dart';
import 'package:petlux/routes/app_router.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  // 1. 获取语言显示名称（跟随系统走国际化词条）
  String _getLocaleName(Locale? locale, S s) {
    if (locale == null) return s.followSystem;
    switch (locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  // 弹出选择语言的底部弹窗
  void _showLanguagePicker(BuildContext context) {
    final s = S.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = localeProvider.locale;
    final supported = S.supportedLocales;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  s.languageSetting,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              // 跟随系统选项
              ListTile(
                title: Text(
                  s.followSystem,
                  style: TextStyle(
                    color: currentLocale == null ? const Color(0xFFF3C746) : const Color(0xFF333333),
                    fontWeight: currentLocale == null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: currentLocale == null ? const Icon(Icons.check, color: Color(0xFFF3C746)) : null,
                onTap: () {
                  localeProvider.setLocale(null);
                  Navigator.pop(ctx);
                },
              ),

              // 自动遍历支持的语言
              ...supported.map((loc) {
                final isSelected = currentLocale?.languageCode == loc.languageCode;
                return ListTile(
                  title: Text(
                    _getLocaleName(loc, s),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFF3C746) : const Color(0xFF333333),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFF3C746)) : null,
                  onTap: () {
                    localeProvider.setLocale(loc);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    const Color primaryGold = Color(0xFFF3C746);
    const Color textColor = Color(0xFF333333);
    const Color subTextColor = Color(0xFF666666);
    const Color bgColor = Color(0xFFF9F9FC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveFormContainer(
          maxWidth: 600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // 顶部用户信息栏
                Selector<UserProvider, (String, String, String)>(
                  selector: (_, vm) => (vm.user.avatarUrl, vm.user.nickname, vm.user.userId),
                  builder: (context, data, _) {
                    final avatarUrl = data.$1;
                    final userName = data.$2;
                    final userId = data.$3;

                    return Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            AppAvatar(avatarUrl: avatarUrl, radius: 32),
                            Positioned(
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: primaryGold, borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  s.user,
                                  style: const TextStyle(
                                    color: Color(0xFF222222),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName.isNotEmpty ? userName : 'User',
                                style: const TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: $userId',
                                style: const TextStyle(fontSize: 12, color: subTextColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Color(0xFF666666), size: 26),
                          onPressed: () {
                            context.push(AppRoutes.personalInfo);
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 功能列表组 A
                Container(
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
                    children: [
                      _buildListTile(
                        Icons.chat_bubble_outline_rounded,
                        const Color(0xFF6BB55B),
                        s.languageSetting,
                        trailingText: _getLocaleName(localeProvider.locale, s),
                        onTap: () => _showLanguagePicker(context),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        Icons.privacy_tip_outlined,
                        const Color(0xFF7C8CEE),
                        s.privacyPolicy,
                        onTap: () {
                          context.push(
                            AppRoutes.webView,
                            extra: {'title': s.privacyPolicy, 'url': AppConstants.privacyPolicyUrl},
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        Icons.description_outlined,
                        const Color(0xFFEE7C8C),
                        s.userAgreement,
                        onTap: () {
                          context.push(
                            AppRoutes.webView,
                            extra: {'title': s.userAgreement, 'url': AppConstants.userAgreementUrl},
                          );
                        },
                      ),
                      _buildDivider(),
                      Selector<UserViewModel, String>(
                        selector: (_, vm) => vm.appVersion,
                        builder: (context, version, _) {
                          return _buildListTile(
                            Icons.dashboard_customize_outlined,
                            const Color(0xFFEEA27C),
                            s.appVersion,
                            trailingText: version,
                            onTap: () {},
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 功能列表组 B
                Container(
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
                    children: [
                      _buildListTile(
                        Icons.lightbulb_outline,
                        const Color(0xFF3B9EBA),
                        s.feedback,
                        onTap: () => context.push(AppRoutes.feedback),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        Icons.info_outline,
                        const Color(0xFF5C7CEE),
                        s.aboutUs,
                        onTap: () => context.push(AppRoutes.aboutUs),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, Color iconColor, String title, {String? trailingText, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (trailingText != null && trailingText.isNotEmpty)
              Text(trailingText, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 52, color: Color(0xFFF0EFF5));
  }
}
