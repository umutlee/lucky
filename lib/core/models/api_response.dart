/// API 響應模型
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? code;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.code,
  });

  /// 創建成功響應
  factory ApiResponse.success(T? data) {
    return ApiResponse(
      isSuccess: true,
      data: data,
    );
  }

  /// 創建錯誤響應
  factory ApiResponse.error({
    String? message,
    int? code,
    T? data,
  }) {
    return ApiResponse(
      isSuccess: false,
      message: message,
      code: code,
      data: data,
    );
  }

  /// 從 JSON 創建實例
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final success = json['success'] as bool? ?? false;
    final code = json['code'] as int?;
    final message = json['message'] as String?;
    final data = json['data'];

    if (success && data != null && fromJson != null) {
      if (data is! Map<String, dynamic>) {
        return ApiResponse.error(
          message: 'Invalid response data format',
          code: 1002,
        );
      }
      return ApiResponse.success(fromJson(data));
    }

    return ApiResponse(
      isSuccess: success,
      code: code,
      message: message,
      data: data as T?,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'success': isSuccess,
      'code': code,
      'message': message,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'ApiResponse{isSuccess: $isSuccess, code: $code, message: $message, data: $data}';
  }
} 