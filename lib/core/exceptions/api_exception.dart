import 'package:dio/dio.dart';
import '../config/api_error_codes.dart';

/// API 異常
class ApiException implements Exception {
  final String message;
  final int code;
  final dynamic data;

  ApiException({
    required this.message,
    required this.code,
    this.data,
  });

  /// 從 DioException 創建實例
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: ApiErrorCodes.getErrorMessage(ApiErrorCodes.timeoutError),
          code: ApiErrorCodes.timeoutError,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? ApiErrorCodes.serverError;
        return ApiException(
          message: ApiErrorCodes.getErrorMessage(statusCode),
          code: statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: ApiErrorCodes.getErrorMessage(ApiErrorCodes.cancelError),
          code: ApiErrorCodes.cancelError,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: ApiErrorCodes.getErrorMessage(ApiErrorCodes.networkError),
          code: ApiErrorCodes.networkError,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: '證書驗證失敗',
          code: ApiErrorCodes.networkError,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? ApiErrorCodes.getErrorMessage(ApiErrorCodes.serverError),
          code: ApiErrorCodes.serverError,
        );
    }
  }

  /// 從響應數據創建實例
  factory ApiException.fromResponse(Map<String, dynamic> response) {
    final code = response['code'] as int? ?? ApiErrorCodes.serverError;
    final message = response['message'] as String? ?? 
                   ApiErrorCodes.getErrorMessage(code);
    final data = response['data'];

    return ApiException(
      message: message,
      code: code,
      data: data,
    );
  }

  /// 從錯誤碼創建實例
  factory ApiException.fromCode(int code) {
    return ApiException(
      message: ApiErrorCodes.getErrorMessage(code),
      code: code,
    );
  }

  /// 是否需要重試
  bool get shouldRetry => ApiErrorCodes.shouldRetry(code);

  /// 是否需要清除緩存
  bool get shouldClearCache => ApiErrorCodes.shouldClearCache(code);

  @override
  String toString() => 'ApiException: [$code] $message';
} 