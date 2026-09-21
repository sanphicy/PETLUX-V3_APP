import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/providers/base_provider.dart';
import 'package:petlux/common/providers/user_provider.dart';
import 'package:petlux/core/network/api_endpoints.dart';
import 'package:petlux/core/network/http_client.dart';
import 'package:petlux/core/network/result_model.dart';
import 'package:petlux/core/services/nav_service.dart';
import 'package:petlux/features/auth/models/auth_request.dart';
import 'package:petlux/features/auth/repositories/auth_repository.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/features/device/active_device_provider.dart';

class UserViewModel extends BaseProvider {
  final UserProvider _userProvider = locator<UserProvider>();
  final AuthRepository _authRepo = locator<AuthRepository>();
  final HttpClient _httpClient = locator<HttpClient>();

  String _appVersion = '';
  String get appVersion => _appVersion;

  S? get _s {
    final BuildContext? ctx = NavService.rootNavigatorKey.currentContext;
    return ctx != null ? S.of(ctx) : null;
  }

  UserViewModel() {
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      notifyListeners();
    } catch (_) {}
  }

  // 修改昵称
  Future<bool> updateNickname(String newName) async {
    final trimmedName = newName.trim();
    final currentUser = _userProvider.user;
    if (trimmedName.isEmpty || trimmedName == currentUser.nickname) return false;

    setLoading(true);
    try {
      final payload = {
        "nickname": trimmedName,
        "countryCode": currentUser.countryCode,
        "timezone": currentUser.timezone,
      };
      final result = await _httpClient.patch<Map<String, dynamic>>(ApiEndpoints.userInfo, data: payload);
      if (result.code == 0 || result.code == 200) {
        _userProvider.updateUser(currentUser.copyWith(nickname: trimmedName));
        return true;
      } else {
        setError(result.message);
      }
    } catch (_) {
      setError(_s?.operationFailed ?? "Failed to update nickname");
    } finally {
      setLoading(false);
    }
    return false;
  }

  // 上传头像
  Future<bool> uploadAvatar(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (image == null) return false;

      setLoading(true);
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(image.path, filename: image.name)});
      final result = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.uploadAvatar, data: formData);
      if (result.data != null && (result.code == 0 || result.code == 200)) {
        final data = result.data!;
        final newAvatar = data['avatarDisplay']?.toString() ?? data['avatar']?.toString();
        if (newAvatar != null && newAvatar.isNotEmpty) {
          _userProvider.updateUser(_userProvider.user.copyWith(avatarUrl: newAvatar));
          return true;
        }
      } else {
        setError(result.message);
      }
    } catch (_) {
      setError(_s?.avatarUploadFailed ?? "Failed to upload avatar");
    } finally {
      setLoading(false);
    }
    return false;
  }

  // 发送注销验证码
  Future<int> sendDeleteAccountCode() async {
    final currentUser = _userProvider.user;
    if (currentUser.account.isEmpty) {
      setError(_s?.noCurrentAccount ?? "Account not found");
      return 0;
    }
    final bool isEmail = currentUser.account.contains('@');
    ResultEntity<int> result;

    if (isEmail) {
      result = await _authRepo.sendEmailVerifyCode(
        SendEmailCodeRequest(email: currentUser.account, purpose: "delete_account"),
      );
    } else {
      final phonePrefix = _userProvider.user.phoneCountryCode;
      result = await _authRepo.sendPhoneVerifyCode(
        SendPhoneCodeRequest(phoneCountryCode: phonePrefix, phone: currentUser.account, purpose: "delete_account"),
      );
    }

    if (result.data != null && result.data! > 0) {
      return result.data!;
    } else {
      setError(result.message);
      return 0;
    }
  }

  // 1. 上传反馈附件图片，返回服务端的图片地址或对象
  Future<String?> uploadFeedbackImage(XFile file) async {
    try {
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(file.path, filename: file.name)});
      // 使用项目通用的上传端点
      final result = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.uploadAvatar, data: formData);
      if (result.data != null && (result.code == 0 || result.code == 200)) {
        final data = result.data!;
        return data['avatarDisplay']?.toString() ?? data['avatar']?.toString() ?? data['url']?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // 提交意见反馈（支持 attachments 字段）
  Future<bool> submitFeedback({
    required String title,
    required String body,
    String? deviceId,
    String? productId,
    List<Map<String, dynamic>> attachments = const [],
    String kind = 'general',
  }) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();

    if (trimmedBody.isEmpty) {
      setError(_s?.emptyAccountOrPassword ?? "Please enter feedback content");
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final Map<String, dynamic> payload = {
        "kind": kind,
        "title": trimmedTitle.isNotEmpty ? trimmedTitle : "App Feedback",
        "body": trimmedBody,
        "priority": "normal",
        "attachments": attachments,
      };

      if (deviceId != null && deviceId.isNotEmpty) {
        payload["deviceId"] = deviceId;
        payload["productId"] = productId ?? "";
      }

      final result = await _httpClient.post<Map<String, dynamic>>(ApiEndpoints.feedbacks, data: payload);

      if (result.code == 0 || result.code == 200) {
        return true;
      } else {
        setError(result.message);
        return false;
      }
    } catch (_) {
      setError(_s?.operationFailed ?? "Failed to submit feedback");
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 执行注销
  Future<bool> deleteAccount(String code) async {
    if (code.trim().isEmpty) {
      setError(_s?.enterEmailCodeHint ?? "Please enter verification code");
      return false;
    }
    setLoading(true);
    clearError();
    try {
      final bool isEmail = _userProvider.user.account.contains('@');
      final channel = isEmail ? "email" : "sms";

      final result = await _authRepo.deleteAccount(DeleteAccountRequest(channel: channel, verificationCode: code));

      if (result.data == true) {
        await _userProvider.logout();
        return true;
      } else {
        setError(result.message);
        return false;
      }
    } catch (_) {
      setError(_s?.deleteAccountFailed ?? "Failed to delete account");
      return false;
    } finally {
      setLoading(false);
    }
  }
}
