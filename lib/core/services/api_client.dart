import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/lunar_date.dart';
import '../models/daily_fortune.dart';
import '../models/study_fortune.dart';
import '../models/career_fortune.dart';
import '../models/love_fortune.dart';
import 'storage_service.dart';

/// API 客戶端
class ApiClient {
  late final Dio _dio;
  final StorageService _storage;
  
  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // 添加攔截器用於日誌記錄
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    // 添加錯誤處理攔截器
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          // 超時重試邏輯
          if (error.requestOptions.extra['retryCount'] == null) {
            error.requestOptions.extra['retryCount'] = 0;
          }
          
          if (error.requestOptions.extra['retryCount'] < ApiConfig.maxRetries) {
            error.requestOptions.extra['retryCount'] += 1;
            await Future.delayed(ApiConfig.retryInterval);
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        return handler.next(error);
      },
    ));
  }

  // 重試請求
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // 處理 API 響應
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          fromJson,
        );
      } else {
        return ApiResponse.error(
          '請求失敗: ${response.statusCode}',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.invalidResponse();
    }
  }

  // 生成緩存 key
  String _getCacheKey(String endpoint, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return '$endpoint${jsonEncode(sortedParams)}';
  }

  // 農曆 API
  Future<ApiResponse<LunarDate>> getLunarDate(DateTime date) async {
    final params = {
      'date': date.toIso8601String(),
      'key': ApiConfig.lunarApiKey,
    };
    final cacheKey = _getCacheKey('lunar', params);
    
    // 嘗試從緩存獲取
    final cached = _storage.getCachedApiResponse(cacheKey, LunarDate.fromJson);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        ApiConfig.getLunarUrl(),
        queryParameters: params,
      );
      final apiResponse = _handleResponse(response, LunarDate.fromJson);
      
      // 緩存成功響應
      if (apiResponse.isSuccess) {
        await _storage.cacheApiResponse(cacheKey, apiResponse);
      }
      
      return apiResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.timeoutError();
      }
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.error('獲取農曆數據失敗: $e');
    }
  }

  // 運勢 API
  Future<ApiResponse<DailyFortune>> getDailyFortune(DateTime date, String type) async {
    final params = {
      'date': date.toIso8601String(),
      'type': type,
      'key': ApiConfig.fortuneApiKey,
    };
    final cacheKey = _getCacheKey('fortune', params);
    
    // 嘗試從緩存獲取
    final cached = _storage.getCachedApiResponse(cacheKey, DailyFortune.fromJson);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        ApiConfig.getFortuneUrl(),
        queryParameters: params,
      );
      final apiResponse = _handleResponse(response, DailyFortune.fromJson);
      
      // 緩存成功響應
      if (apiResponse.isSuccess) {
        await _storage.cacheApiResponse(cacheKey, apiResponse);
      }
      
      return apiResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.timeoutError();
      }
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.error('獲取運勢數據失敗: $e');
    }
  }

  // 學業運勢 API
  Future<ApiResponse<StudyFortune>> getStudyFortune(DateTime date) async {
    final params = {
      'date': date.toIso8601String(),
      'key': ApiConfig.studyFortuneApiKey,
    };
    final cacheKey = _getCacheKey('study-fortune', params);
    
    // 嘗試從緩存獲取
    final cached = _storage.getCachedApiResponse(cacheKey, StudyFortune.fromJson);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        ApiConfig.getStudyFortuneUrl(),
        queryParameters: params,
      );
      final apiResponse = _handleResponse(response, StudyFortune.fromJson);
      
      // 緩存成功響應
      if (apiResponse.isSuccess) {
        await _storage.cacheApiResponse(cacheKey, apiResponse);
      }
      
      return apiResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.timeoutError();
      }
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.error('獲取學業運勢失敗: $e');
    }
  }

  // 事業運勢 API
  Future<ApiResponse<CareerFortune>> getCareerFortune(DateTime date) async {
    final params = {
      'date': date.toIso8601String(),
      'key': ApiConfig.careerFortuneApiKey,
    };
    final cacheKey = _getCacheKey('career-fortune', params);
    
    // 嘗試從緩存獲取
    final cached = _storage.getCachedApiResponse(cacheKey, CareerFortune.fromJson);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        ApiConfig.getCareerFortuneUrl(),
        queryParameters: params,
      );
      final apiResponse = _handleResponse(response, CareerFortune.fromJson);
      
      // 緩存成功響應
      if (apiResponse.isSuccess) {
        await _storage.cacheApiResponse(cacheKey, apiResponse);
      }
      
      return apiResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.timeoutError();
      }
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.error('獲取事業運勢失敗: $e');
    }
  }

  // 愛情運勢 API
  Future<ApiResponse<LoveFortune>> getLoveFortune(
    DateTime date,
    String zodiacSign,
  ) async {
    final params = {
      'date': date.toIso8601String(),
      'zodiac': zodiacSign,
      'key': ApiConfig.loveFortuneApiKey,
    };
    final cacheKey = _getCacheKey('love-fortune', params);
    
    // 嘗試從緩存獲取
    final cached = _storage.getCachedApiResponse(cacheKey, LoveFortune.fromJson);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        ApiConfig.getLoveFortuneUrl(),
        queryParameters: params,
      );
      final apiResponse = _handleResponse(response, LoveFortune.fromJson);
      
      // 緩存成功響應
      if (apiResponse.isSuccess) {
        await _storage.cacheApiResponse(cacheKey, apiResponse);
      }
      
      return apiResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse.timeoutError();
      }
      return ApiResponse.networkError();
    } catch (e) {
      return ApiResponse.error('獲取愛情運勢失敗: $e');
    }
  }
} 