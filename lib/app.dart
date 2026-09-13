// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petlux/common/config/app_config.dart';
import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/theme/app_theme.dart';
import 'package:petlux/features/device/device_provider.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/routes/app_router.dart';
import 'package:petlux/common/constants/dimens.dart';
import 'package:petlux/common/providers/user_provider.dart';

// 全局语言通知器
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString('app_language_code');
    if (langCode != null && langCode.isNotEmpty) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('app_language_code');
    } else {
      await prefs.setString('app_language_code', locale.languageCode);
    }
  }
}

class MyApp extends StatefulWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

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
    _router = AppRouter.createRouter(widget.initialLocation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()), // 注入语言通知
        ChangeNotifierProvider.value(value: locator<UserProvider>()),
        ChangeNotifierProvider.value(value: locator<DeviceProvider>()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return ScreenUtilInit(
            designSize: Dimens.designSize,
            minTextAdapt: true,
            splitScreenMode: true,
            fontSizeResolver: _resolveFontSize,
            builder: (context, child) {
              return MaterialApp.router(
                title: locator<AppConfig>().appName,
                debugShowCheckedModeBanner: false,
                routerConfig: _router,
                locale: localeProvider.locale, // 响应当前设置的语言
                supportedLocales: S.supportedLocales,
                localizationsDelegates: _localizationsDelegates,
                theme: AppTheme.lightTheme,
              );
            },
          );
        },
      ),
    );
  }
}
