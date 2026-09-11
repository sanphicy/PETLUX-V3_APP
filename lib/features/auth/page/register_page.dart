import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:petlux/common/config/app_constants.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/models/country_dto.dart';
import 'package:petlux/common/widgets/app_dialogs.dart';
import 'package:petlux/features/auth/viewmodels/register_view_model.dart';
import 'package:petlux/features/auth/widgets/country_picker_sheet.dart';
import 'package:petlux/routes/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final TextEditingController _confirmPwdCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();

  bool _obscurePwd = true;
  bool _obscureConfirmPwd = true;
  bool _agreedPrivacy = false;

  int _countdown = 0;
  final ValueNotifier<bool> _isSendingCode = ValueNotifier(false);

  // 与截图 1:1 对齐的标准暖金黄与浅灰胶囊底色
  static const Color _primaryGold = Color(0xFFE6BA47);
  static const Color _btnYellow = Color(0xFFF3C746);
  static const Color _inputGrey = Color(0xFFECEEF0);
  static const Color _borderGrey = Color(0xFFDCDFE3);

  static final RegExp _emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _codeCtrl.dispose();
    _isSendingCode.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    setState(() => _countdown = seconds);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_countdown > 0) {
        setState(() => _countdown--);
        return true;
      }
      return false;
    });
  }

  Future<void> _handleSendCode(RegisterViewModel vm, S s) async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      context.showAppToast(message: s.emptyAccountOrPassword, type: AppToastType.warning);
      return;
    }
    if (!_emailRegExp.hasMatch(email)) {
      context.showAppToast(message: s.invalidAccountFormat, type: AppToastType.warning);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    _isSendingCode.value = true;
    final cooldown = await vm.sendVerifyCode(email, false);
    if (mounted) _isSendingCode.value = false;

    if (cooldown > 0) {
      _startCountdown(cooldown);
    } else if (vm.hasError && mounted) {
      context.showAppToast(message: vm.errorMsg, type: AppToastType.error);
    }
  }

  Future<void> _handleRegister(RegisterViewModel vm, S s) async {
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text.trim();
    final confirmPwd = _confirmPwdCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (email.isEmpty || pwd.isEmpty || confirmPwd.isEmpty || code.isEmpty) {
      context.showAppToast(message: s.emptyAccountOrPassword, type: AppToastType.warning);
      return;
    }

    if (!_emailRegExp.hasMatch(email)) {
      context.showAppToast(message: s.invalidAccountFormat, type: AppToastType.warning);
      return;
    }

    if (pwd != confirmPwd) {
      context.showAppToast(message: s.passwordMismatch, type: AppToastType.warning);
      return;
    }

    if (!_agreedPrivacy) {
      context.showAppToast(
        message: '${s.agreePrefix}${s.userAgreement} & ${s.privacyPolicy}',
        type: AppToastType.warning,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final success = await vm.register(account: email, password: pwd, code: code, isPhoneMode: false);

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.tabDevice);
    } else {
      context.showAppToast(message: vm.errorMsg.isNotEmpty ? vm.errorMsg : s.operationFailed, type: AppToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final vm = context.watch<RegisterViewModel>();
    final mediaQuery = MediaQuery.of(context);

    // 顶部黄色区域深度恰好容纳标题，白色拱弧向上深推
    final double cardTop = mediaQuery.padding.top + 78.0;

    return Scaffold(
      backgroundColor: _primaryGold,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. 顶部通透黄色 Header 区域
          Positioned(
            top: mediaQuery.padding.top,
            left: 0,
            right: 0,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 左侧大返回箭头
                Positioned(
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E), size: 28),
                    onPressed: () => context.pop(),
                  ),
                ),
                // 居中大号标题
                Text(
                  s.register,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // 2. 白色主体大圆弧卡片（44r 大圆角深弧）
          Positioned(
            top: cardTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(44)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 38),

                  // E-mail 标题与加粗黄色下横线
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 7,
                        width: 72,
                        margin: const EdgeInsets.only(bottom: 2),
                        color: _btnYellow.withValues(alpha: 0.85),
                      ),
                      Text(
                        s.emailTitle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF222222)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Container(
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFEFEFF2), borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Selector<RegisterViewModel, CountryDto?>(
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
                                  context.read<RegisterViewModel>().switchCountry(selected);
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
                        Expanded(
                          child: TextField(
                            controller: _emailCtrl, // 如果你的控制器叫 _accountCtrl 则保持原名
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

                  const SizedBox(height: 16),

                  // 2. 密码输入框
                  _buildCapsuleField(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pwdCtrl,
                            obscureText: _obscurePwd,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF222222)),
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
                          onTap: () => setState(() => _obscurePwd = !_obscurePwd),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              _obscurePwd ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF222222),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. 确认密码输入框
                  _buildCapsuleField(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _confirmPwdCtrl,
                            obscureText: _obscureConfirmPwd,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF222222)),
                            decoration: InputDecoration(
                              hintText: s.confirmPasswordHint,
                              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _obscureConfirmPwd = !_obscureConfirmPwd),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              _obscureConfirmPwd ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF222222),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. 验证码发送区（白底细边胶囊 + 灰底验证码输入框）
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isSendingCode,
                        builder: (context, isSending, _) {
                          return GestureDetector(
                            onTap: (_countdown > 0 || isSending) ? null : () => _handleSendCode(vm, s),
                            child: Container(
                              height: 52,
                              constraints: const BoxConstraints(minWidth: 96),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderGrey, width: 1.2),
                              ),
                              child: Center(
                                child: isSending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF222222)),
                                      )
                                    : Text(
                                        _countdown > 0 ? '${_countdown}s' : s.sendCode,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _countdown > 0 ? Colors.grey : const Color(0xFF333333),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCapsuleField(
                          child: TextField(
                            controller: _codeCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF222222)),
                            decoration: InputDecoration(
                              hintText: s.enterEmailCodeHint,
                              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 5. 协议勾选行
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _agreedPrivacy = !_agreedPrivacy),
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1, right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _agreedPrivacy ? _btnYellow : const Color(0xFFC8CBD0),
                              width: 1.5,
                            ),
                            color: _agreedPrivacy ? _btnYellow : Colors.white,
                          ),
                          child: _agreedPrivacy ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF555555), height: 1.45),
                            children: [
                              TextSpan(text: s.agreePrefix),
                              TextSpan(
                                text: s.userAgreement,
                                style: const TextStyle(color: Color(0xFF5394E8)),
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
                                style: const TextStyle(color: Color(0xFF5394E8)),
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

                  // 6. 黄色长条提交按钮（Submit and register）
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _btnYellow,
                        foregroundColor: const Color(0xFF1E1E1E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: vm.isLoading ? null : () => _handleRegister(vm, s),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.black54, strokeWidth: 2),
                            )
                          : Text(
                              s.register,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: mediaQuery.padding.bottom > 0 ? mediaQuery.padding.bottom + 12 : 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleField({required Widget child}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(color: _inputGrey, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: child,
    );
  }
}
