/// API 響應模型
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? code;
  final String? error;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.code,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromJson(json['data'] as Map<String, dynamic>) : null,
      code: json['code'] as int?,
      error: json['error'] as String?,
    );
  }

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: '請求成功',
    );
  }

  factory ApiResponse.error(String message, {int? code, String? error}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      code: code,
      error: error,
    );
  }

  factory ApiResponse.networkError() {
    return ApiResponse<T>(
      success: false,
      message: '網絡連接失敗，請檢查網絡設置',
      code: -1,
    );
  }

  factory ApiResponse.serverError() {
    return ApiResponse<T>(
      success: false,
      message: '服務器錯誤，請稍後重試',
      code: 500,
    );
  }

  factory ApiResponse.timeoutError() {
    return ApiResponse<T>(
      success: false,
      message: '請求超時，請稍後重試',
      code: -2,
    );
  }

  factory ApiResponse.invalidResponse() {
    return ApiResponse<T>(
      success: false,
      message: '無效的響應數據',
      code: -3,
    );
  }

  bool get isSuccess => success && data != null;
  bool get isError => !success || data == null;
} 