import 'package:flutter/material.dart';
import 'package:v3/core/network/api_endpoints.dart';
import 'package:v3/core/network/http_client.dart';
import 'package:v3/core/result/result_model.dart';
import 'package:v3/core/utils/token_manager.dart';
import 'package:v3/locator.dart';
import 'package:v3/features/auth/models/auth_request.dart';

class AuthRepository {
  final HttpClient _httpClient = locator<HttpClient>();

  Future<ResultEntity<bool>> loginByphone(PhoneLoginRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.loginByPhone, data: request.toJson());
    if (response.data != null && (response.code == 0 || response.code == 200)) {
      final accessToken = response.data!['accessToken'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenManager.setToken(accessToken);
        return ResultEntity.success(true); // 仅返回成功状态
      } else {
        return ResultEntity.error("获取 Token 失败");
      }
    }
    return ResultEntity.error(response.message);
  }

  Future<ResultEntity<bool>> loginByEmail(EmailLoginRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.loginByEmail, data: request.toJson());
    if (response.data != null && (response.code == 0 || response.code == 200)) {
      final accessToken = response.data!['accessToken'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenManager.setToken(accessToken);
        return ResultEntity.success(true); // 仅返回成功状态
      } else {
        return ResultEntity.error("获取 Token 失败");
      }
    }
    return ResultEntity.error(response.message);
  }

  Future<ResultEntity<bool>> sendVerifyCode(SendCodeRequest request) async {
    debugPrint("==== [API Mock] Sent verify code to: ${request.email} (${request.type}) ====");
    return ResultEntity.success(true);
  }

  Future<ResultEntity<bool>> register(RegisterRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.register, data: request.toJson());
    if (response.data != null && (response.code == 0 || response.code == 200)) {
      final accessToken = response.data!['accessToken'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await TokenManager.setToken(accessToken);
        return ResultEntity.success(true);
      } else {
        return ResultEntity.error("获取 Token 失败");
      }
    }
    return ResultEntity.error(response.message);
  }

  Future<ResultEntity<bool>> resetPassword(ResetPasswordRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.resetPassword, data: request.toJson());
    if (response.code == 0 || response.code == 200) {
      return ResultEntity.success(true);
    }
    return ResultEntity.error(response.message);
  }
}
