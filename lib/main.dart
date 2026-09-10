// main.dart
import 'package:flutter/material.dart';
import 'package:petlux/core/utils/device_batch_helper.dart';
import 'package:petlux/core/storage/token_manager.dart';
import 'package:petlux/core/services/region_service.dart';
import 'package:petlux/routes/app_router.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/app.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 保持原生启动图，直到 Flutter 第一帧渲染
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz_data.initializeTimeZones();

  // 注入容器
  setupLocator();

  // 设备批次映射预加载
  try {
    await DeviceBatchHelper().init();
  } catch (e) {
    debugPrint("设备ID映射初始化失败: $e");
  }

  // 提前检查登录态并初始化区域服务
  String initialLocation = AppRoutes.login;
  try {
    final bool loggedIn = await TokenManager.isLoggedIn();
    await locator<RegionService>().initBootstrap(isLoggedIn: loggedIn);
    initialLocation = loggedIn ? AppRoutes.tabDevice : AppRoutes.login;
  } catch (e) {
    debugPrint("启动引导初始化失败: $e");
    initialLocation = AppRoutes.login;
  }

  // 挂载 UI 树，传入计算好的首页路由
  runApp(MyApp(initialLocation: initialLocation));
}
