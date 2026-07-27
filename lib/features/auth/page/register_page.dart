import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:v3/common/constants/dimens.dart';
import 'package:v3/common/l10n/app_localizations.dart';
import 'package:v3/features/auth/widgets/auth_text_field.dart';
import 'package:v3/features/auth/widgets/auth_verify_code_field.dart';
import 'package:v3/features/auth/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  final ValueNotifier<bool> _isSubmitting = ValueNotifier(false);
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final primaryColor = const Color(0xFFF3D14B);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.register,
          style: TextStyle(color: Colors.black, fontSize: Dimens.fontLarge, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: Dimens.spacingNormal),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              padding: EdgeInsets.symmetric(horizontal: Dimens.pagePadding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Dimens.spacingXLarge),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            s.emailLabel,
                            style: TextStyle(
                              fontSize: Dimens.fontLarge,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: Dimens.spacingMini),
                            height: 4.h,
                            width: 60.w,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimens.spacingXLarge),
                    AuthTextField(controller: _emailCtrl, hintText: s.emailHint),
                    SizedBox(height: Dimens.spacingNormal),
                    AuthTextField(controller: _passwordCtrl, hintText: s.passwordHint, isPassword: true),
                    SizedBox(height: Dimens.spacingNormal),
                    AuthTextField(hintText: s.confirmPassword, isPassword: true), // 新增国际化
                    SizedBox(height: Dimens.spacingNormal),
                    AuthVerifyCodeField(
                      controller: _codeCtrl,
                      onSendCode: () async {
                        return await context.read<LoginProvider>().sendVerifyCode(_emailCtrl.text, "Email");
                      },
                    ),
                    SizedBox(height: Dimens.spacingLarge),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Container(
                            margin: EdgeInsets.only(top: 2.h, right: 8.w),
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _agreedToTerms ? primaryColor : Colors.black26),
                              color: _agreedToTerms ? primaryColor : Colors.transparent,
                            ),
                            child: _agreedToTerms ? Icon(Icons.check, size: 14.w, color: Colors.white) : null,
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                              children: [
                                TextSpan(text: s.agreePrefix),
                                TextSpan(
                                  text: s.userAgreement,
                                  style: const TextStyle(color: Colors.lightBlue),
                                ),
                                TextSpan(text: s.andText),
                                TextSpan(
                                  text: s.privacyPolicy,
                                  style: const TextStyle(color: Colors.lightBlue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60.h),

                    // --- 局部刷新构建提交按钮 ---
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSubmitting,
                      builder: (context, isSubmitting, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: Dimens.buttonLarge,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.radiusLarge)),
                              elevation: 0,
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!_agreedToTerms) return;
                                    FocusManager.instance.primaryFocus?.unfocus();

                                    _isSubmitting.value = true;
                                    final provider = context.read<LoginProvider>();
                                    final success = await provider.register(
                                      _emailCtrl.text,
                                      _passwordCtrl.text,
                                      _codeCtrl.text,
                                      "CN",
                                    );
                                    if (mounted) _isSubmitting.value = false;

                                    if (success && mounted) {
                                      Navigator.pop(this.context);
                                    }
                                  },
                            child: isSubmitting
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(color: Colors.black),
                                  )
                                : Text(
                                    s.submitAndRegister,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: Dimens.fontLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
