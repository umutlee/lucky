import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../config/api_error_codes.dart';
import '../exceptions/api_exception.dart';

/// API 攔截器
class ApiInterceptor extends Interceptor {
  int _retryCount = 0;
  final int maxRetries;
  final Duration retryInterval;
  final Dio _dio;

  ApiInterceptor({
    this.maxRetries = ApiConfig.maxRetries,
    this.retryInterval = ApiConfig.retryInterval,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加通用請求頭
    options.headers.addAll(ApiConfig.headers);
    
    // 添加時間戳防止緩存
    if (options.method.toUpperCase() == 'GET') {
      options.queryParameters['_t'] = DateTime.now().millisecondsSinceEpoch;
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 重置重試計數
    _retryCount = 0;

    // 檢查響應格式
    if (response.data is! Map<String, dynamic>) {
      throw ApiException(
        message: ApiErrorCodes.getErrorMessage(ApiErrorCodes.invalidResponse),
        code: ApiErrorCodes.invalidResponse,
      );
    }

    // 檢查業務邏輯錯誤
    final data = response.data as Map<String, dynamic>;
    final success = data['success'] as bool? ?? false;
    final code = data['code'] as int?;

    if (!success || code != null) {
      throw ApiException.fromResponse(data);
    }

    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 轉換為 ApiException
    final error = ApiException.fromDioException(err);

    // 檢查是否需要重試
    if (error.shouldRetry && _retryCount < maxRetries) {
      _retryCount++;
      
      // 等待重試間隔
      await Future.delayed(retryInterval);
      
      // 重試請求
      try {
        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        );
        
        final response = await _dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: options,
        );
        
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // 重置重試計數
    _retryCount = 0;

    // 處理特定錯誤
    if (error.code == ApiErrorCodes.unauthorized) {
      // TODO: 處理未授權錯誤，例如跳轉到登錄頁面
    }

    return handler.next(err);
  }

  /// 檢查網絡連接
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
} 