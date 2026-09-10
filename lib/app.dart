// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'package:petlux/common/config/app_config.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/theme/app_theme.dart';
import 'package:petlux/features/device/device_provider.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/routes/app_router.dart';
import 'package:petlux/common/constants/dimens.dart';
import 'package:petlux/common/providers/user_provider.dart';

class MyApp extends StatefulWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const List<LocalizationsDelegate<dynamic>> _localizationsDelegates = [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static double _resolveFontSize(num fontSize, ScreenUtil instance) {
    final scale = instance.scaleText;
    return fontSize * (scale > 1.2 ? 1.2 : scale);
  }

  @override
  void initState() {
    super.initState();
    // 首帧渲染出来后立即移除原生系统启动屏，无缝露出 LoginPage 或首页
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locator<UserProvider>()),
        ChangeNotifierProvider.value(value: locator<DeviceProvider>()),
      ],
      child: ScreenUtilInit(
        designSize: Dimens.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        fontSizeResolver: _resolveFontSize,
        builder: (context, child) {
          return MaterialApp.router(
            title: locator<AppConfig>().appName,
            debugShowCheckedModeBanner: false,
            // 动态传入计算好的路由
            routerConfig: AppRouter.createRouter(widget.initialLocation),
            supportedLocales: S.supportedLocales,
            localizationsDelegates: _localizationsDelegates,
            theme: AppTheme.lightTheme,
          );
        },
      ),
    );
  }
}
