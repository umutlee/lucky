import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/services/encryption_service.dart';
import 'package:all_lucky/core/utils/api_key_generator.dart';

final secureApiClientProvider = Provider<SecureApiClient>((ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  return SecureApiClient(encryptionService);
});

/// 安全的 API 客戶端
class SecureApiClient {
  static const String _tag = 'SecureApiClient';
  final _logger = Logger(_tag);
  
  final EncryptionService _encryptionService;
  final Dio _dio;
  
  SecureApiClient(this._encryptionService) : _dio = Dio() {
    _initializeClient();
  }
  
  void _initializeClient() {
    _dio.options.baseUrl = 'https://api.alllucky.com'; // TODO: 使用正確的API地址
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // 添加請求攔截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // 生成 API Key
          final apiKey = await _generateApiKey();
          options.headers['X-API-Key'] = apiKey;
          
          // 如果請求體不為空，加密數據
          if (options.data != null) {
            final jsonData = jsonEncode(options.data);
            final encryptedData = _encryptionService.encrypt(jsonData);
            options.data = {'data': encryptedData};
          }
          
          handler.next(options);
        } catch (e, stackTrace) {
          _logger.error('請求攔截器錯誤', e, stackTrace);
          handler.reject(
            DioException(
              requestOptions: options,
              error: '請求準備失敗',
            ),
          );
        }
      },
      onResponse: (response, handler) async {
        try {
          // 如果響應體是加密的，解密數據
          if (response.data != null && response.data['data'] != null) {
            final encryptedData = response.data['data'] as String;
            final decryptedData = _encryptionService.decrypt(encryptedData);
            response.data = jsonDecode(decryptedData);
          }
          
          handler.next(response);
        } catch (e, stackTrace) {
          _logger.error('響應攔截器錯誤', e, stackTrace);
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: '響應解密失敗',
            ),
          );
        }
      },
    ));
  }
  
  /// 生成 API Key
  Future<String> _generateApiKey() async {
    const environment = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
    const appId = String.fromEnvironment('APP_ID', defaultValue: 'com.alllucky.app');
    
    return ApiKeyGenerator.generateKey(
      environment: environment,
      appId: appId,
    );
  }
  
  /// 發送 GET 請求
  Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e, stackTrace) {
      _logger.error('GET 請求失敗: $path', e, stackTrace);
      rethrow;
    }
  }
  
  /// 發送 POST 請求
  Future<T?> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e, stackTrace) {
      _logger.error('POST 請求失敗: $path', e, stackTrace);
      rethrow;
    }
  }
  
  /// 發送 PUT 請求
  Future<T?> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e, stackTrace) {
      _logger.error('PUT 請求失敗: $path', e, stackTrace);
      rethrow;
    }
  }
  
  /// 發送 DELETE 請求
  Future<T?> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e, stackTrace) {
      _logger.error('DELETE 請求失敗: $path', e, stackTrace);
      rethrow;
    }
  }
  
  /// 關閉客戶端
  void dispose() {
    _dio.close();
  }
} 