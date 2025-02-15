import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';
import '../exceptions/api_exception.dart';

/// API 客戶端提供者
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.read(storageServiceProvider),
  );
});

/// API 客戶端
class ApiClient {
  final StorageService _storage;
  final Dio _dio;

  ApiClient(
    this._storage, {
    Dio? dio,
    String? baseUrl,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl ?? ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// 發送 GET 請求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options ?? Options(headers: ApiConfig.headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  /// 發送 POST 請求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: ApiConfig.headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  /// 發送 PUT 請求
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: ApiConfig.headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  /// 發送 DELETE 請求
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(headers: ApiConfig.headers),
        cancelToken: cancelToken,
      );
      
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<bool> isConnected() async {
    try {
      final response = await _dio.get('/ping');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void close() {
    _dio.close();
  }
} 