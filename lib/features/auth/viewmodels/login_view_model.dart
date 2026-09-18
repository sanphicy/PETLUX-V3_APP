import 'package:flutter/material.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/models/country_dto.dart';
import 'package:petlux/common/providers/base_provider.dart';
import 'package:petlux/core/network/result_model.dart';
import 'package:petlux/core/services/nav_service.dart';
import 'package:petlux/core/services/region_service.dart';
import 'package:petlux/features/auth/models/auth_request.dart';
import 'package:petlux/features/auth/repositories/auth_repository.dart';
import 'package:petlux/locator.dart';

class LoginViewModel extends BaseProvider {
  final AuthRepository _authRepo = locator<AuthRepository>();
  final RegionService _regionService = locator<RegionService>();

  CountryDto? get currentCountry => _regionService.currentCountry;

  // 获取全局国际化实例
  S? get _s {
    final BuildContext? ctx = NavService.rootNavigatorKey.currentContext;
    return ctx != null ? S.of(ctx) : null;
  }

  Future<void> switchCountry(CountryDto country) async {
    await _regionService.switchCountry(country);
    notifyListeners();
  }

  // 纯邮箱登录
  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      setError(_s?.emptyAccountOrPassword ?? "Please fill in all fields");
      return false;
    }
    setLoading(true);
    clearError();

    final ResultEntity<bool> result = await _authRepo.loginByEmail(
      EmailLoginRequest(email: email.trim(), password: password.trim()),
    );

    setLoading(false);
    if (result.data == true) {
      return true;
    } else {
      setError(result.message);
      return false;
    }
  }
}
