import 'package:petlux/common/providers/base_provider.dart';
import 'package:petlux/core/services/region_service.dart';
import 'package:petlux/core/network/result_model.dart';
import 'package:petlux/features/auth/models/auth_request.dart';
import 'package:petlux/features/auth/repositories/auth_repository.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/common/models/country_dto.dart';
import 'package:flutter/material.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/core/services/nav_service.dart';

class RegisterViewModel extends BaseProvider {
  final AuthRepository _authRepo = locator<AuthRepository>();
  final RegionService _regionService = locator<RegionService>();

  CountryDto? get currentCountry => _regionService.currentCountry;

  S? get _s {
    final BuildContext? ctx = NavService.rootNavigatorKey.currentContext;
    return ctx != null ? S.of(ctx) : null;
  }

  Future<void> switchCountry(CountryDto country) async {
    await _regionService.switchCountry(country);
    notifyListeners();
  }

  Future<int> sendVerifyCode(String account, [bool isPhoneMode = false]) async {
    if (account.trim().isEmpty) {
      setError(_s?.enterEmailHint ?? "Please enter your email");
      return 0;
    }
    final result = await _authRepo.sendEmailVerifyCode(SendEmailCodeRequest(email: account, purpose: "register"));
    if (result.data != null && result.data! > 0) {
      return result.data!;
    } else {
      setError(result.message);
      return 0;
    }
  }

  Future<bool> register({
    required String account,
    required String password,
    required String code,
    required bool isPhoneMode,
  }) async {
    if (account.trim().isEmpty || password.trim().isEmpty || code.trim().isEmpty) {
      setError(_s?.emptyAccountOrPassword ?? "Please fill in all fields");
      return false;
    }
    setLoading(true);
    clearError();

    final countryCode = currentCountry?.countryCode ?? "CN";
    final phonePrefix = currentCountry?.phoneCountryCode ?? "+86";

    ResultEntity<bool> result;
    if (isPhoneMode) {
      result = await _authRepo.registerByPhone(
        PhoneRegisterRequest(
          phoneCountryCode: phonePrefix,
          phone: account,
          password: password,
          verificationCode: code,
          countryCode: countryCode,
        ),
      );
    } else {
      result = await _authRepo.registerByEmail(
        RegisterRequest(email: account, password: password, verificationCode: code, countryCode: countryCode),
      );
    }

    setLoading(false);
    if (result.data == true) {
      return true;
    } else {
      setError(result.message);
      return false;
    }
  }
}
