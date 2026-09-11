import 'package:petlux/common/providers/base_provider.dart';
import 'package:petlux/core/services/region_service.dart';
import 'package:petlux/core/network/result_model.dart';
import 'package:petlux/features/auth/models/auth_request.dart';
import 'package:petlux/features/auth/repositories/auth_repository.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/common/models/country_dto.dart';

class LoginViewModel extends BaseProvider {
  final AuthRepository _authRepo = locator<AuthRepository>();
  final RegionService _regionService = locator<RegionService>();

  CountryDto? get currentCountry => _regionService.currentCountry;

  Future<void> switchCountry(CountryDto country) async {
    // 1. 立即持久化并切换底层机房 BaseUrl
    await _regionService.switchCountry(country);
    // 2. 强制通知 LoginPage 刷新内嵌的国家展示
    notifyListeners();
  }

  //登录
  Future<bool> login(String account, String password, {required bool isEmail}) async {
    if (account.trim().isEmpty || password.trim().isEmpty) {
      setError("请填写完整信息");
      return false;
    }
    setLoading(true);
    clearError();

    ResultEntity<bool> result;
    if (isEmail) {
      result = await _authRepo.loginByEmail(EmailLoginRequest(email: account, password: password));
    } else {
      final phonePrefix = currentCountry?.phoneCountryCode ?? "+86";
      result = await _authRepo.loginByPhone(
        PhoneLoginRequest(phoneCountryCode: phonePrefix, phone: account, password: password),
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
