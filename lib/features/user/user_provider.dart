import 'package:v3/common/providers/base_provider.dart';
import 'package:v3/core/utils/token_manager.dart';
import 'package:v3/core/navigation/nav_service.dart';
import 'package:v3/routes/app_router.dart';
import 'package:v3/locator.dart';
import 'package:v3/common/providers/user_provider.dart' as global_user;

import 'package:v3/core/network/api_endpoints.dart';
import 'package:v3/core/network/http_client.dart';
import 'package:v3/common/models/user_dto.dart';

class UserProvider extends BaseProvider {
  String _userName = '';
  String _userId = '';

  final String _avatarUrl = 'assets/images/petlux-top_bg.png';

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

  // 初始化获取用户信息
  Future<void> fetchUserInfo() async {
    setLoading(true);

    final currentUser = locator<global_user.UserProvider>().currentUser;

    if (currentUser != null) {
      _userName = currentUser.nickname ?? 'Unknown User';
      _userId = currentUser.userId;
    } else {
      // 检查 Token 并去获取用户数据
      final isLoggedIn = await TokenManager.isLoggedIn();

      if (isLoggedIn) {
        try {
          final result = await locator<HttpClient>().get<Map<String, dynamic>>(ApiEndpoints.userInfo);

          if (result.data != null && (result.code == 0 || result.code == 200)) {
            final data = result.data!;

            final fetchedUser = UserDto(
              userId: data['userId']?.toString() ?? '',
              phone: data['phone']?.toString(),
              nickname: data['nickname']?.toString(),
              email: data['email']?.toString(),
            );

            locator<global_user.UserProvider>().setUser(fetchedUser);

            _userName = fetchedUser.nickname ?? 'Unknown User';
            _userId = fetchedUser.userId;
          } else if (result.code == 401) {
            // 重点：处理 Token 过期/无效的情况，直接踢回登录页
            await logout();
            return; // 终止后续操作
          } else {
            _userName = 'Unknown';
            _userId = '-';
            setError(result.message);
          }
        } catch (e) {
          _userName = 'Unknown';
          _userId = '-';
          setError("Failed to fetch user data: $e");
        }
      } else {
        _userName = 'Unknown';
        _userId = '-';
        await logout(); // 抽离出一个本地强退方法也可以
      }
    }

    setLoading(false);
    notifyListeners();
  }

  // 登出逻辑
  Future<void> logout() async {
    try {
      await locator<HttpClient>().post<Map<String, dynamic>>(ApiEndpoints.logout);
    } finally {
      await TokenManager.clearToken();
      locator<global_user.UserProvider>().clearUser();
      NavService.go(AppRoutes.login);
    }
  }
}
