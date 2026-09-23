import 'package:dio/dio.dart';
import 'package:petlux/core/network/result_model.dart';
import 'package:petlux/core/network/auth_interceptor.dart';
import 'package:petlux/core/network/api_exception.dart';
import 'package:petlux/core/services/nav_service.dart';
import 'package:petlux/routes/app_router.dart';
import 'package:petlux/core/storage/token_manager.dart';
import 'package:flutter/material.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  late Dio dio;

  HttpClient._internal();

  void init({required String baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"X-Client-App": "petlux"},
      ),
    );
    dio.interceptors.add(AuthInterceptor(dio));
    dio.options.baseUrl = baseUrl;
  }

  Future<ResultEntity<T>> request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final options = Options(method: method, headers: headers);

      debugPrint('\n================== API REQUEST ==================');
      debugPrint('URL    : ${dio.options.baseUrl}$path');
      debugPrint('METHOD : $method');
      if (queryParameters != null) debugPrint('QUERY  : $queryParameters');
      if (data != null) debugPrint('BODY   : $data');
      debugPrint('=================================================\n');

      final response = await dio.request(path, data: data, queryParameters: queryParameters, options: options);
      final resData = response.data;

      // 打印成功的响应数据
      debugPrint('\n================== API RESPONSE =================');
      debugPrint('URL    : ${dio.options.baseUrl}$path');
      debugPrint('STATUS : ${response.statusCode}');
      debugPrint('DATA   : $resData');
      debugPrint('=================================================\n');

      if (resData is Map<String, dynamic>) {
        final dynamic rawCode = resData['code'];
        final int? code = rawCode is int ? rawCode : int.tryParse(rawCode?.toString() ?? '');
        if (code == 200 || code == 0) {
          final rawData = resData['data'];
          final T? finalData = (fromJson != null && rawData != null) ? fromJson(rawData) : rawData as T?;
          return ResultEntity.success(finalData, msg: resData['message'] ?? '请求成功');
        }
        if (code == 401 || (code != null && code.toString().startsWith('401'))) {
          _handleUnauthorized();
          return ResultEntity.error(resData['message'] ?? '登录已失效', code: code);
        }
        return ResultEntity.error(resData['message'] ?? '请求失败', code: code);
      }
      return ResultEntity.error('未知数据格式');
    } catch (e) {
      if (e is TypeError || e is FormatException) {
        return ResultEntity.error('数据解析异常');
      }

      if (e is DioException) {
        // 打印异常的响应数据（HTTP 错误状态码，比如 400, 401, 500 等）
        debugPrint('\n================== API ERROR ====================');
        debugPrint('URL    : ${dio.options.baseUrl}$path');
        debugPrint('STATUS : ${e.response?.statusCode}');
        debugPrint('ERROR  : ${e.type}');
        debugPrint('DATA   : ${e.response?.data}');
        debugPrint('=================================================\n');

        if (e.type == DioExceptionType.badResponse) {
          final resData = e.response?.data;
          if (resData is Map<String, dynamic>) {
            return ResultEntity.error(
              resData['message'] ?? ApiException.format(e),
              code: resData['code'],
              requestId: resData['requestId'],
            );
          }
        }
      }
      return ResultEntity.error(ApiException.format(e));
    }
  }

  /// 处理登录失效逻辑
  void _handleUnauthorized() async {
    await TokenManager.clearToken();
    // 使用 NavService 全局导航回登录页
    NavService.go(AppRoutes.login);
  }

  Future<ResultEntity<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) => request<T>(path, method: 'PATCH', data: data, headers: headers, fromJson: fromJson);
  Future<ResultEntity<T>> get<T>(String path, {Map<String, dynamic>? query, T Function(dynamic)? fromJson}) =>
      request<T>(path, method: 'GET', queryParameters: query, fromJson: fromJson);

  Future<ResultEntity<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) => request<T>(path, method: 'POST', data: data, headers: headers, fromJson: fromJson);

  Future<ResultEntity<T>> put<T>(String path, {dynamic data, T Function(dynamic)? fromJson}) =>
      request<T>(path, method: 'PUT', data: data, fromJson: fromJson);

  Future<ResultEntity<T>> delete<T>(String path, {dynamic data, T Function(dynamic)? fromJson}) =>
      request<T>(path, method: 'DELETE', data: data, fromJson: fromJson);
}
