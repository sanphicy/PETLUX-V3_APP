import 'package:v3/common/models/user_dto.dart';
import 'package:v3/common/providers/base_provider.dart';
import 'package:v3/locator.dart';
import 'models/auth_request.dart';
import 'repositories/auth_repository.dart';
import 'package:v3/core/result/result_model.dart';
import 'package:v3/common/providers/user_provider.dart';

class LoginProvider extends BaseProvider {
  // 注册仓库
  final AuthRepository _authRepo = locator<AuthRepository>();

  // 登录操作
  Future<bool> login(String account, String password, {required bool isEmail}) async {
    if (account.trim().isEmpty || password.trim().isEmpty) {
      setError("请输入账号和密码");
      return false;
    }

    setLoading(true);
    clearError();

    ResultEntity<UserDto> result;

    if (isEmail) {
      final request = EmailLoginRequest(email: account, password: password);
      result = await _authRepo.loginByEmail(request);
    } else {
      final request = PhoneLoginRequest(phoneCountryCode: "+86", phone: account, password: password);
      result = await _authRepo.loginByphone(request);
    }

    if (isLoading) setLoading(false);

    if (result.data != null) {
      locator<UserProvider>().setUser(result.data!);
      return true;
    } else {
      setError(result.message);
      return false;
    }
  }

  /// 发送验证码业务
  Future<bool> sendVerifyCode(String email, String type) async {
    if (email.trim().isEmpty) {
      setError("Please enter your email first");
      return false;
    }

    final result = await _authRepo.sendVerifyCode(SendCodeRequest(email: email, type: type));

    if (result.data == true) {
      return true;
    } else {
      setError(result.message);
      return false;
    }
  }

  /// 注册业务
  Future<bool> register(String email, String password, String code, String countryCode) async {
    if (email.trim().isEmpty || password.trim().isEmpty || code.trim().isEmpty) {
      setError("Please fill in all fields");
      return false;
    }
    final result = await _authRepo.register(
      RegisterRequest(email: email, password: password, verificationCode: code, countryCode: countryCode),
    );
    if (result.data == true) {
      return true;
    } else {
      setError(result.message);
      return false;
    }
  }

  /// 重置密码业务
  Future<bool> resetPassword(String email, String newPassword, String code) async {
    if (email.trim().isEmpty || newPassword.trim().isEmpty || code.trim().isEmpty) {
      setError("Please fill in all fields");
      return false;
    }
    final result = await _authRepo.resetPassword(
      ResetPasswordRequest(email: email, newPassword: newPassword, verificationCode: code),
    );
    if (result.data == true) {
      return true;
    } else {
      setError(result.message);
      return false;
    }
  }
}
