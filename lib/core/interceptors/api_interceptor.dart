import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../config/api_error_codes.dart';
import '../exceptions/api_exception.dart';
import '../services/cache_service.dart';
import '../utils/logger.dart';

/// API 攔截器
class ApiInterceptor extends Interceptor {
  int _retryCount = 0;
  final int maxRetries;
  final Duration retryInterval;
  final Dio _dio;
  final CacheService _cacheService;
  final _logger = Logger('ApiInterceptor');

  ApiInterceptor({
    this.maxRetries = ApiConfig.maxRetries,
    this.retryInterval = ApiConfig.retryInterval,
    Dio? dio,
    required CacheService cacheService,
  }) : _dio = dio ?? Dio(), _cacheService = cacheService;

  @override
  Future<void> onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler,
  ) async {
    // 檢查是否需要緩存
    if (options.extra['useCache'] == true) {
      final cacheKey = _generateCacheKey(options);
      try {
        final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
        if (cached != null) {
          _logger.info('使用緩存數據: $cacheKey');
          return handler.resolve(
            Response(
              requestOptions: options,
              data: cached,
              statusCode: 200,
            ),
          );
        }
      } catch (e) {
        _logger.warning('讀取緩存失敗', e);
      }
    }
    
    // 添加通用請求頭
    options.headers.addAll(ApiConfig.headers);
    
    // 添加時間戳防止緩存
    if (options.method.toUpperCase() == 'GET') {
      options.queryParameters['_t'] = DateTime.now().millisecondsSinceEpoch;
    }

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // 如果需要緩存響應
    if (response.requestOptions.extra['useCache'] == true) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final duration = response.requestOptions.extra['cacheDuration'] as Duration? 
          ?? const Duration(hours: 1);
          
      try {
        await _cacheService.set(
          cacheKey,
          response.data,
          expiration: duration,
        );
        _logger.info('緩存響應數據: $cacheKey');
      } catch (e) {
        _logger.warning('緩存響應失敗', e);
      }
    }
    
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

  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final method = options.method;
    final params = options.queryParameters.toString();
    return '$method:$uri:$params';
  }
} 