import 'package:v3/common/providers/base_provider.dart';
import 'package:v3/core/utils/token_manager.dart';
import 'package:v3/core/navigation/nav_service.dart';
import 'package:v3/routes/app_router.dart';
import 'package:v3/locator.dart';
import 'package:v3/core/network/api_endpoints.dart';
import 'package:v3/core/network/http_client.dart';

class UserProvider extends BaseProvider {
  String _userName = 'Unknown User';
  String _userId = '-';
  String _avatarUrl = '';
  int _catCount = 0;
  int _dayCount = 0;
  int _deviceCount = 0;

  // Getters
  String get userName => _userName;
  String get userId => _userId;
  String get avatarUrl => _avatarUrl;
  int get catCount => _catCount;
  int get dayCount => _dayCount;
  int get deviceCount => _deviceCount;

  /// 拉取用户信息
  /// [isSilent] 为 true 时，不展示加载动画，且不向上抛出阻断性错误（冷启动/后台切入适用）
  Future<void> fetchUserInfo({bool isSilent = false}) async {
    final isLoggedIn = await TokenManager.isLoggedIn();
    if (!isLoggedIn) {
      await logout();
      return;
    }

    // 只有在非静默请求，且当前内存中确实没有数据时，才展示 Loading
    if (!isSilent && _userId == '-') {
      setLoading(true);
    }

    try {
      final result = await locator<HttpClient>().get<Map<String, dynamic>>(ApiEndpoints.userInfo);
      if (result.data != null && (result.code == 0 || result.code == 200)) {
        final data = result.data!;

        final newName = data['nickname']?.toString() ?? 'Unknown User';
        final newId = data['userId']?.toString() ?? '-';
        final newAvatar = data['avatar']?.toString() ?? _avatarUrl;
        if (_userName != newName || _userId != newId) {
          _userName = newName;
          _userId = newId;
          _avatarUrl = newAvatar;
          print(_avatarUrl);
          notifyListeners();
        }
      } else if (result.code == 401) {
        await logout();
      } else if (!isSilent) {
        setError(result.message);
      }
    } catch (e) {
      if (!isSilent) {
        setError("Failed to fetch user data: $e");
      }
    } finally {
      if (isLoading) setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await locator<HttpClient>().post<Map<String, dynamic>>(ApiEndpoints.logout);
    } catch (_) {
      // 忽略登出时的网络错误
    } finally {
      await TokenManager.clearToken();
      _userName = 'Unknown User';
      _userId = '-';
      NavService.go(AppRoutes.login);
    }
  }
}
