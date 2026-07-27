import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:v3/routes/app_router.dart';
import 'package:v3/features/auth/auth_provider.dart';
import 'package:v3/common/l10n/app_localizations.dart';
import 'package:v3/common/constants/dimens.dart';
import 'package:v3/features/auth/widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final ValueNotifier<bool> _isSubmitting = ValueNotifier(false);
  bool _agreedToTerms = false;

  final Color _primaryYellow = const Color(0xFFF3D14B);
  final Color _darkBgColor = const Color(0xFF262626);
  final Color _textColor = const Color(0xFF333333);
  final Color _linkColor = const Color(0xFF63A0B7);

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final double dynamicTopPosition = screenWidth * 0.28;

    return Scaffold(
      backgroundColor: _darkBgColor,
      body: Stack(
        children: [
          Positioned(
            top: dynamicTopPosition,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: Dimens.pagePadding, vertical: Dimens.spacingXLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 14.h,
                          width: 80.w,
                          color: _primaryYellow,
                          margin: EdgeInsets.only(bottom: Dimens.spacingMini),
                        ),
                        Text(
                          s.emailLabel,
                          style: TextStyle(fontSize: Dimens.fontHuge, fontWeight: FontWeight.w900, color: _textColor),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimens.spacingXLarge),
                    AuthTextField(controller: _accountCtrl, hintText: s.emailHint),
                    SizedBox(height: Dimens.spacingNormal),
                    AuthTextField(controller: _passwordCtrl, hintText: s.passwordHint, isPassword: true),
                    SizedBox(height: Dimens.spacingNormal),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50.w, 30.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          s.forgotPassword,
                          style: TextStyle(color: Colors.black87, fontSize: Dimens.fontNormal),
                        ),
                      ),
                    ),
                    SizedBox(height: Dimens.spacingNormal),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Container(
                            margin: EdgeInsets.only(top: 2.h, right: 10.w),
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _agreedToTerms ? _primaryYellow : Colors.grey.shade400,
                                width: Dimens.borderNormal,
                              ),
                              color: _agreedToTerms ? _primaryYellow : Colors.transparent,
                            ),
                            child: _agreedToTerms ? Icon(Icons.check, size: 14.w, color: Colors.white) : null,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: _textColor, fontSize: 13.sp, height: 1.5),
                              children: [
                                TextSpan(text: s.agreePrefix),
                                TextSpan(
                                  text: s.userAgreement,
                                  style: TextStyle(color: _linkColor),
                                ),
                                TextSpan(text: s.andText),
                                TextSpan(
                                  text: s.privacyPolicy,
                                  style: TextStyle(color: _linkColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimens.spacingXLarge),

                    ValueListenableBuilder<bool>(
                      valueListenable: _isSubmitting,
                      builder: (context, isSubmitting, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: Dimens.buttonLarge,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!_agreedToTerms) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(SnackBar(content: Text(s.agreeTermsPrompt)));
                                      return;
                                    }
                                    FocusManager.instance.primaryFocus?.unfocus();

                                    final account = _accountCtrl.text.trim();
                                    final password = _passwordCtrl.text.trim();

                                    if (account.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(SnackBar(content: Text(s.emptyAccountOrPassword))); //
                                      return;
                                    }

                                    final bool isEmail = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    ).hasMatch(account);
                                    final bool isPhone = RegExp(r'^1[3-9]\d{9}$').hasMatch(account);

                                    if (!isEmail && !isPhone) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(SnackBar(content: Text(s.invalidAccountFormat)));
                                      return;
                                    }

                                    _isSubmitting.value = true;
                                    final provider = context.read<LoginProvider>();
                                    final success = await provider.login(account, password, isEmail: isEmail);

                                    if (mounted) _isSubmitting.value = false;

                                    if (success && mounted) {
                                      this.context.go(AppRoutes.home);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryYellow,
                              foregroundColor: _textColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.radiusLarge)),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? SizedBox(
                                    width: Dimens.iconNormal,
                                    height: Dimens.iconNormal,
                                    child: CircularProgressIndicator(color: _textColor, strokeWidth: 2),
                                  )
                                : Text(
                                    s.login,
                                    style: TextStyle(
                                      color: _textColor,
                                      fontSize: Dimens.fontLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: Dimens.spacingNormal),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: Text(
                        s.register,
                        style: TextStyle(color: Colors.black87, fontSize: Dimens.fontMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
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
        ],
      ),
    );
  }
}
