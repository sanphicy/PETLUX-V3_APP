import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petlux/common/config/app_config.dart';
import 'package:petlux/common/models/country_dto.dart';
import 'package:petlux/core/network/api_endpoints.dart';
import 'package:petlux/core/network/http_client.dart';
import 'package:petlux/locator.dart';
import 'package:dio/dio.dart';

// 区域/国家服务 - 多国家、多数据中心切换
class RegionService {
  static const String _keyCountryList = 'cache_country_list';
  static const String _keySelectedCountryCode = 'pref_selected_country_code';
  static const String _keyCurrentBaseUrl = 'pref_current_api_base_url';

  List<CountryDto> _countries = [];
  CountryDto? _currentCountry;
  String _currentApiBaseUrl = '';

  final Map<String, String> _dcUrlCache = {};

  List<CountryDto> get countries => _countries;
  CountryDto? get currentCountry => _currentCountry;
  String get currentApiBaseUrl => _currentApiBaseUrl;

  // 兜底国家预设
  static final List<CountryDto> _fallbackCountries = [
    CountryDto(
      name: '中国',
      countryCode: 'CN',
      phoneCountryCode: '+86',
      defaultDataRegion: 'CN',
      defaultDataCenter: 'CN',
    ),
    CountryDto(
      name: 'United States',
      countryCode: 'US',
      phoneCountryCode: '+1',
      defaultDataRegion: 'US',
      defaultDataCenter: 'US',
    ),
    CountryDto(
      name: '中国香港',
      countryCode: 'HK',
      phoneCountryCode: '+852',
      defaultDataRegion: 'CN',
      defaultDataCenter: 'CN',
    ),
  ];

  // 启动引导：0 毫秒首屏启动优化
  Future<void> initBootstrap({required bool isLoggedIn}) async {
    final prefs = await SharedPreferences.getInstance();

    // 已登录用户：直接读缓存的 BaseUrl，0ms 进入首页
    if (isLoggedIn) {
      final savedBaseUrl = prefs.getString(_keyCurrentBaseUrl);
      if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
        _currentApiBaseUrl = savedBaseUrl;
        locator<HttpClient>().init(baseUrl: _currentApiBaseUrl);
        loadCountryList(); // 后台静默预热国家列表
        return;
      }
    }

    // 先从本地缓存/内存装载国家，不阻塞主线程
    await _loadCountryListFromCacheOnly();

    // 检查是否有历史选择的国家
    final savedCode = prefs.getString(_keySelectedCountryCode);
    if (savedCode != null && _countries.any((c) => c.countryCode == savedCode)) {
      _currentCountry = _countries.firstWhere((c) => c.countryCode == savedCode);
    } else {
      // 首次安装无缓存：纯按系统语言分配初始大区
      _currentCountry = _matchDefaultCountryByLanguage();
    }

    final countryCode = _currentCountry?.countryCode ?? 'CN';

    // 检查是否有缓存的机房 URL，有则直接使用，无则请求引导接口
    final savedBaseUrl = prefs.getString(_keyCurrentBaseUrl);
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      _currentApiBaseUrl = savedBaseUrl;
      locator<HttpClient>().init(baseUrl: _currentApiBaseUrl);
      // 异步刷新机房地址与国家列表
      switchCountryByCode(countryCode);
      loadCountryList();
    } else {
      await switchCountryByCode(countryCode);
      loadCountryList();
    }
  }

  // 仅从内存与磁盘缓存快速加载（不发起网络请求）
  Future<void> _loadCountryListFromCacheOnly() async {
    if (_countries.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final cachedStr = prefs.getString(_keyCountryList);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(cachedStr);
        _countries = list.map((e) => CountryDto.fromJson(e)).toList();
      } catch (_) {}
    }
    if (_countries.isEmpty) {
      _countries = List.from(_fallbackCountries);
    }
  }

  // 异步从服务端拉取最新的国家列表
  Future<List<CountryDto>> loadCountryList() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final config = AppConfig.prod();
      // 🟢 改用原生局部 Dio，绝不影响全局 HttpClient
      final tempDio = Dio(
        BaseOptions(
          baseUrl: config.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final currentLocale = ui.PlatformDispatcher.instance.locale;
      final localeParam = currentLocale.languageCode.toLowerCase() == 'zh' ? 'zh-CN' : 'en-US';

      final response = await tempDio.get<Map<String, dynamic>>(
        ApiEndpoints.countries,
        queryParameters: {'locale': localeParam, 'clientAppId': 'petlux'},
      );

      final resData = response.data;
      if (resData != null && (resData['code'] == 0 || resData['code'] == 200)) {
        final List<dynamic> items = resData['items'] ?? [];
        if (items.isNotEmpty) {
          _countries = items.map((e) => CountryDto.fromJson(e)).toList();
          await prefs.setString(_keyCountryList, jsonEncode(items));

          // 刷新当前选中的国家对象
          if (_currentCountry != null) {
            _currentCountry = _countries.firstWhere(
              (c) => c.countryCode == _currentCountry!.countryCode,
              orElse: () => _currentCountry!,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Country List Error: $e");
    }

    if (_countries.isEmpty) {
      _countries = List.from(_fallbackCountries);
    }
    return _countries;
  }

  // 用户手动改选国家：0ms 乐观更新，后台静默寻址
  Future<bool> switchCountry(CountryDto country) async {
    // 内存与强凭证立即生效（乐观更新）
    _currentCountry = country;

    // 立即落盘用户选择的国家代码，保证下次打开依然是这个国家
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedCountryCode, country.countryCode);
    } catch (_) {}

    // 后台静默发起机房地址同步，不 await 阻塞 UI
    _silentFetchAndApplyBaseUrl(country.countryCode);

    return true; // 立即放行！
  }

  // 后台静默获取机房节点并应用
  void _silentFetchAndApplyBaseUrl(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();

    // 如果内存缓存有，直接应用并落盘，完全不发网络请求
    if (_dcUrlCache.containsKey(countryCode)) {
      _currentApiBaseUrl = _dcUrlCache[countryCode]!;
      locator<HttpClient>().init(baseUrl: _currentApiBaseUrl);
      await prefs.setString(_keyCurrentBaseUrl, _currentApiBaseUrl);
      return;
    }

    //  内存没有，后台静默发起网络请求
    try {
      final config = AppConfig.prod();
      final tempClient = HttpClient();
      tempClient.init(baseUrl: config.baseUrl);

      final payload = {"countryCode": countryCode, "clientAppId": "petlux"};
      final res = await tempClient.get<Map<String, dynamic>>(ApiEndpoints.mqttUri, query: payload);

      if (res.code == 0 || res.code == 200) {
        final data = res.data;
        if (data != null && data['apiBaseUrl'] != null) {
          String apiBaseUrl = data['apiBaseUrl'].toString();
          if (apiBaseUrl.endsWith('/app')) {
            apiBaseUrl = apiBaseUrl.substring(0, apiBaseUrl.length - 4);
          }
          _currentApiBaseUrl = apiBaseUrl;
          _dcUrlCache[countryCode] = _currentApiBaseUrl;

          // 切换全局网络客户端的 BaseUrl 并落盘
          locator<HttpClient>().init(baseUrl: _currentApiBaseUrl);
          await prefs.setString(_keyCurrentBaseUrl, _currentApiBaseUrl);
        }
      }
    } catch (e) {
      debugPrint("后台静默拉取机房节点失败: $e");
    }
  }

  Future<bool> switchCountryByCode(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();

    if (_dcUrlCache.containsKey(countryCode)) {
      _currentApiBaseUrl = _dcUrlCache[countryCode]!;
      locator<HttpClient>().init(baseUrl: _currentApiBaseUrl);
      await prefs.setString(_keyCurrentBaseUrl, _currentApiBaseUrl);
      return true;
    }

    final config = AppConfig.prod();
    try {
      // 🟢 改用原生局部 Dio
      final tempDio = Dio(
        BaseOptions(
          baseUrl: config.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final payload = {"countryCode": countryCode, "clientAppId": "petlux"};
      final response = await tempDio.get<Map<String, dynamic>>(ApiEndpoints.mqttUri, queryParameters: payload);

      final resData = response.data;
      if (resData != null && (resData['code'] == 0 || resData['code'] == 200)) {
        final data = resData['data'];
        if (data != null && data['apiBaseUrl'] != null) {
          String apiBaseUrl = data['apiBaseUrl'].toString();
          if (apiBaseUrl.endsWith('/app')) {
            apiBaseUrl = apiBaseUrl.substring(0, apiBaseUrl.length - 4);
          }
          _currentApiBaseUrl = apiBaseUrl;
          _dcUrlCache[countryCode] = _currentApiBaseUrl;

          // 仅在这里更新全局 HttpClient 并落盘
          locator<HttpClient>().init(baseUrl: _currentApiBaseUrl);
          await prefs.setString(_keyCurrentBaseUrl, _currentApiBaseUrl);
          return true;
        }
      }
    } catch (e) {
      debugPrint("Switch Country / DC Error: $e");
    }
    return false;
  }

  // 纯按系统语言分配初始大区（对齐霍曼逻辑）
  CountryDto _matchDefaultCountryByLanguage() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final lang = systemLocale.languageCode.toLowerCase();

    // 1. 系统主语言是中文，分配中国大区
    if (lang == 'zh') {
      return _countries.firstWhere((c) => c.countryCode.toUpperCase() == 'CN', orElse: () => _fallbackCountries.first);
    }

    // 2. 其它语言，优先按地区后缀匹配（如 GB、DE 等），匹配不到默认美区 US
    final sysRegion = systemLocale.countryCode?.toUpperCase();
    if (sysRegion != null && sysRegion.isNotEmpty && sysRegion != 'CN') {
      final matched = _countries.firstWhere(
        (c) => c.countryCode.toUpperCase() == sysRegion,
        orElse: () =>
            _countries.firstWhere((c) => c.countryCode.toUpperCase() == 'US', orElse: () => _fallbackCountries[1]),
      );
      return matched;
    }

    // 3. 兜底美区
    return _countries.firstWhere((c) => c.countryCode.toUpperCase() == 'US', orElse: () => _fallbackCountries[1]);
  }
}
