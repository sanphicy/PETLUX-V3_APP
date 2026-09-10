import 'package:petlux/common/providers/base_provider.dart';
import 'package:petlux/core/services/region_service.dart';
import 'package:petlux/core/network/result_model.dart';
import 'package:petlux/features/auth/models/auth_request.dart';
import 'package:petlux/features/auth/repositories/auth_repository.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/common/models/country_dto.dart';

class RegisterViewModel extends BaseProvider {
  final AuthRepository _authRepo = locator<AuthRepository>();
  final RegionService _regionService = locator<RegionService>();

  CountryDto? get currentCountry => _regionService.currentCountry;

  Future<void> switchCountry(CountryDto country) async {
    // 立即通知 UI 乐观渲染新选中的国家
    notifyListeners();

    // 后台异步执行 BaseURL 切换与缓存
    final success = await _regionService.switchCountry(country);
    if (!success) {
      // 若失败则重绘回退
      notifyListeners();
    }
  }

  Future<int> sendVerifyCode(String account, [bool isPhoneMode = false]) async {
    if (account.trim().isEmpty) {
      setError("请输入邮箱");
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
      setError("请填写完整注册信息");
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
