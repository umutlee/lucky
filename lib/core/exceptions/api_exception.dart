import 'package:dio/dio.dart';
import '../config/api_error_codes.dart';

/// API 異常
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  /// 從 DioException 創建實例
  factory ApiException.fromDioException(DioException error) {
    late String message;
    late int statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '連接超時，請檢查網絡連接';
        statusCode = 408;
        break;

      case DioExceptionType.badResponse:
        final response = error.response;
        message = response?.data?['message'] ?? '伺服器錯誤';
        statusCode = response?.statusCode ?? 500;
        break;

      case DioExceptionType.cancel:
        message = '請求已取消';
        statusCode = 499;
        break;

      case DioExceptionType.connectionError:
        message = '網絡連接錯誤，請檢查網絡設置';
        statusCode = 503;
        break;

      case DioExceptionType.badCertificate:
        message = '證書驗證失敗';
        statusCode = 495;
        break;

      case DioExceptionType.unknown:
        message = '未知錯誤';
        statusCode = 520;
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  /// 從響應數據創建實例
  factory ApiException.fromResponse(Map<String, dynamic> response) {
    final code = response['code'] as int? ?? ApiErrorCodes.serverError;
    final message = response['message'] as String? ?? 
                   ApiErrorCodes.getErrorMessage(code);
    final data = response['data'];

    return ApiException(
      message: message,
      statusCode: code,
      data: data,
    );
  }

  /// 從錯誤碼創建實例
  factory ApiException.fromCode(int code) {
    return ApiException(
      message: ApiErrorCodes.getErrorMessage(code),
      statusCode: code,
    );
  }

  /// 是否需要重試
  bool get shouldRetry => ApiErrorCodes.shouldRetry(statusCode);

  /// 是否需要清除緩存
  bool get shouldClearCache => ApiErrorCodes.shouldClearCache(statusCode);

  bool get isNetworkError =>
      statusCode == 408 || statusCode == 503 || statusCode == 520;

  bool get isAuthError => statusCode == 401 || statusCode == 403;

  bool get isServerError => statusCode >= 500 && statusCode < 600;

  bool get isClientError => statusCode >= 400 && statusCode < 500;

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
} 