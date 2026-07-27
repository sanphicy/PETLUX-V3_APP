import 'package:flutter/material.dart';
import 'package:v3/common/config/app_config.dart';
import 'package:v3/core/utils/token_manager.dart';
import 'package:v3/core/network/http_client.dart';
import 'package:v3/locator.dart';
import 'package:v3/routes/app_router.dart';
import 'package:v3/app.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  setupLocator();

  final config = AppConfig.prod();
  TokenManager.init(accessKey: config.accessTokenKey);
  locator<HttpClient>().init(baseUrl: config.baseUrl);

  bool loggedIn = await TokenManager.isLoggedIn();
  String initialRoute = loggedIn ? AppRoutes.home : AppRoutes.login;

  AppRouter.setup(initialRoute);

  runApp(const MyApp());
}
