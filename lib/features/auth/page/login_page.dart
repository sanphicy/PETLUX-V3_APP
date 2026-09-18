import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:petlux/common/config/app_constants.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/widgets/app_dialogs.dart';
import 'package:petlux/features/auth/viewmodels/login_view_model.dart';
import 'package:petlux/routes/app_router.dart';

import 'package:petlux/common/models/country_dto.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedPrivacy = false;

  static const Color _brandYellow = Color(0xFFF2C94C);
  static const Color _inputBg = Color(0xFFEFEFF2);
  static const Color _darkHeaderBg = Color(0xFF262626);

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  static final RegExp _emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  Future<void> _handleLogin(LoginViewModel vm, S s) async {
    final account = _accountCtrl.text.trim();
    final pwd = _passwordCtrl.text.trim();

    if (account.isEmpty) {
      context.showAppToast(message: s.enterEmailHint, type: AppToastType.warning);
      return;
    }

    if (pwd.isEmpty) {
      context.showAppToast(message: s.enterPasswordHint, type: AppToastType.warning);
      return;
    }

    if (!_emailRegExp.hasMatch(account)) {
      context.showAppToast(message: s.invalidAccountFormat, type: AppToastType.warning);
      return;
    }
    //隐私政策是否勾选
    if (!_agreedPrivacy) {
      context.showAppToast(
        message: '${s.agreePrefix}${s.userAgreement} & ${s.privacyPolicy}',
        type: AppToastType.warning,
      );
      return;
    }
    //全局收起软键盘
    FocusManager.instance.primaryFocus?.unfocus();

    final success = await vm.login(account, pwd);

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.tabDevice);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final vm = context.watch<LoginViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final double cardTop = mediaQuery.padding.top + (screenWidth * 0.30);
    return Scaffold(
      backgroundColor: _darkHeaderBg, // 顶部状态栏和深色背景统一
      resizeToAvoidBottomInset: false, // 严禁键盘挤压和弹性滚动
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: cardTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // E-mail 标题与黄色横线装饰
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 7,
                        width: 68,
                        margin: const EdgeInsets.only(bottom: 2),
                        color: _brandYellow.withValues(alpha: 0.8),
                      ),
                      Text(
                        s.emailTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF222222),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Selector<LoginViewModel, CountryDto?>(
                          selector: (_, m) => m.currentCountry,
                          builder: (context, currentCountry, _) {
                            final displayName = currentCountry?.name.isNotEmpty == true
                                ? currentCountry!.name
                                : (currentCountry?.countryCode ?? 'US');

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                final selected = await context.push<CountryDto>(AppRoutes.countrySearch);
                                if (selected != null && context.mounted) {
                                  vm.switchCountry(selected);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 88),
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF222222),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF666666)),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 1,
                                    height: 18,
                                    color: const Color(0xFFD0D0D4),
                                    margin: const EdgeInsets.only(right: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // 邮箱输入框
                        Expanded(
                          child: TextField(
                            controller: _accountCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                            decoration: InputDecoration(
                              hintText: s.enterEmailHint,
                              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 密码输入框
                  Container(
                    height: 48,
                    decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                            decoration: InputDecoration(
                              hintText: s.enterPasswordHint,
                              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF444444),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 忘记密码
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: Text(s.forgotPassword, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 协议勾选行
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _agreedPrivacy = !_agreedPrivacy),
                        child: Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1, right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _agreedPrivacy ? _brandYellow : const Color(0xFFC8C8C8),
                              width: 1.5,
                            ),
                            color: _agreedPrivacy ? _brandYellow : Colors.white,
                          ),
                          child: _agreedPrivacy ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.4),
                            children: [
                              TextSpan(text: s.agreePrefix),
                              TextSpan(
                                text: s.userAgreement,
                                style: const TextStyle(color: Color(0xFF5B9BF3)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(
                                      AppRoutes.webView,
                                      extra: {'title': s.userAgreement, 'url': AppConstants.userAgreementUrl},
                                    );
                                  },
                              ),
                              TextSpan(text: s.andText),
                              TextSpan(
                                text: s.privacyPolicy,
                                style: const TextStyle(color: Color(0xFF5B9BF3)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(
                                      AppRoutes.webView,
                                      extra: {'title': s.privacyPolicy, 'url': AppConstants.privacyPolicyUrl},
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandYellow,
                        foregroundColor: const Color(0xFF222222),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: vm.isLoading ? null : () => _handleLogin(vm, s),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.black54, strokeWidth: 2),
                            )
                          : Text(
                              s.login,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222222),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 去注册
                  TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: Text(
                      s.register,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontWeight: FontWeight.w500),
                    ),
                  ),

                  SizedBox(height: mediaQuery.padding.bottom > 0 ? mediaQuery.padding.bottom : 16),
                ],
              ),
            ),
          ),

          // 【上层】：猫咪素材层，透明通道叠在白卡片上方
          // IgnorePointer 避免阻挡下方白卡片可能存在的点击事件
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.only(top: mediaQuery.padding.top),
                child: Image.asset('assets/images/login_cat_header.png', width: screenWidth, fit: BoxFit.fitWidth),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
