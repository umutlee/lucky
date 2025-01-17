import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/api_error_codes.dart';
import '../exceptions/api_exception.dart';
import '../interceptors/api_interceptor.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

/// API 客戶端
class ApiClient {
  late final Dio _dio;
  final StorageService _storage;
  final ApiInterceptor _apiInterceptor;
  
  ApiClient(this._storage, {Dio? dio}) : _apiInterceptor = ApiInterceptor() {
    _dio = dio ?? Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
    ));

    // 添加攔截器
    _dio.interceptors.add(_apiInterceptor);

    // 添加日誌攔截器（僅在調試模式下）
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// 發送 GET 請求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool forceRefresh = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // 檢查網絡連接
      if (!await _apiInterceptor.checkConnection()) {
        throw ApiException.fromCode(ApiErrorCodes.networkError);
      }

      // 嘗試從緩存獲取（如果未強制刷新）
      if (!forceRefresh && fromJson != null) {
        final cacheKey = _getCacheKey(path, queryParameters);
        final cached = await _storage.getCachedFortune<T>(cacheKey);
        if (cached != null) {
          return ApiResponse.success(cached);
        }
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options ?? Options(headers: ApiConfig.headers),
      );

      final result = _handleResponse(response, fromJson);

      // 緩存成功響應
      if (result.isSuccess && fromJson != null) {
        final cacheKey = _getCacheKey(path, queryParameters);
        await _storage.cacheFortune(cacheKey, result.data);
      }

      return result;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: e.toString(),
        code: ApiErrorCodes.serverError,
      );
    }
  }

  /// 發送 POST 請求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // 檢查網絡連接
      if (!await _apiInterceptor.checkConnection()) {
        throw ApiException.fromCode(ApiErrorCodes.networkError);
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: ApiConfig.headers),
      );

      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: e.toString(),
        code: ApiErrorCodes.serverError,
      );
    }
  }

  /// 處理響應數據
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      if (response.data is! Map<String, dynamic>) {
        throw ApiException.fromCode(ApiErrorCodes.invalidResponse);
      }

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;
      final code = data['code'] as int?;
      final message = data['message'] as String?;
      final responseData = data['data'];

      if (!success || code != null) {
        throw ApiException(
          message: message ?? ApiErrorCodes.getErrorMessage(code ?? ApiErrorCodes.serverError),
          code: code ?? ApiErrorCodes.serverError,
          data: responseData,
        );
      }

      if (fromJson != null && responseData != null) {
        if (responseData is! Map<String, dynamic>) {
          throw ApiException.fromCode(ApiErrorCodes.invalidResponse);
        }
        return ApiResponse.success(fromJson(responseData));
      }

      return ApiResponse.success(responseData as T?);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.fromCode(ApiErrorCodes.parseError);
    }
  }

  /// 生成緩存鍵
  String _getCacheKey(String path, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return path;
    
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    return '$path?${_encodeParams(sortedParams)}';
  }

  /// 編碼請求參數
  String _encodeParams(Map<String, dynamic> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  /// 清除緩存
  Future<void> clearCache() async {
    await _storage.clearAllCache();
  }
} 