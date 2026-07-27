import 'package:flutter/material.dart';
import 'package:v3/core/network/api_endpoints.dart';
import 'package:v3/core/network/http_client.dart';
import 'package:v3/core/result/result_model.dart';
import 'package:v3/core/utils/token_manager.dart';
import 'package:v3/locator.dart';
import 'package:v3/features/auth/models/auth_request.dart';
import 'package:v3/common/models/user_dto.dart';

class AuthRepository {
  final HttpClient _httpClient = locator<HttpClient>();

  // 邮箱登录
  // 手机号登录接口
  Future<ResultEntity<UserDto>> loginByphone(PhoneLoginRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.loginByPhone, data: request.toJson());

    if (response.data != null && (response.code == 0 || response.code == 200)) {
      final data = response.data!;
      final accessToken = data['accessToken'] as String?;

      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenManager.setToken(accessToken);

        // 提取所需的用户信息
        final user = UserDto(
          userId: data['userId']?.toString() ?? '',
          phone: data['phone']?.toString(),
          nickname: data['nickname']?.toString(),
          email: data['email']?.toString(),
        );

        return ResultEntity.success(user); // 返回 user 对象
      } else {
        return ResultEntity.error("Failed to get Token");
      }
    }
    return ResultEntity.error(response.message);
  }

  // 登录
  Future<ResultEntity<UserDto>> loginByEmail(EmailLoginRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.loginByEmail, data: request.toJson());

    if (response.data != null && (response.code == 0 || response.code == 200)) {
      final data = response.data!;
      final accessToken = data['accessToken'] as String?;

      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenManager.setToken(accessToken);

        final user = UserDto(
          userId: data['userId']?.toString() ?? '',
          phone: data['phone']?.toString(),
          nickname: data['nickname']?.toString(),
          email: data['email']?.toString(),
        );

        return ResultEntity.success(user); // 返回 user 对象
      } else {
        return ResultEntity.error("Failed to get Token");
      }
    }
    return ResultEntity.error(response.message);
  }

  // 发送验证码
  Future<ResultEntity<bool>> sendVerifyCode(SendCodeRequest request) async {
    debugPrint("==== [API Mock] Sent verify code to: ${request.email} (${request.type}) ====");
    return ResultEntity.success(true);
  }

  // 注册
  Future<ResultEntity<bool>> register(RegisterRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.register, data: request.toJson());
    if (response.data != null && (response.code == 0 || response.code == 200)) {
      final accessToken = response.data!['accessToken'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenManager.setToken(accessToken);
        return ResultEntity.success(true);
      } else {
        return ResultEntity.error("Failed to get Token");
      }
    }
    return ResultEntity.error(response.message);
  }

  // 重置密码
  Future<ResultEntity<bool>> resetPassword(ResetPasswordRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.resetPassword, data: request.toJson());
    if (response.code == 0 || response.code == 200) {
      return ResultEntity.success(true);
    }
    return ResultEntity.error(response.message);
  }
}
