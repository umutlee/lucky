import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';
part 'app_error.g.dart';

enum ErrorType {
  network,    // 網絡錯誤
  validation, // 數據驗證錯誤
  permission, // 權限錯誤
  server,     // 服務器錯誤
  unknown     // 未知錯誤
}

class StackTraceConverter implements JsonConverter<StackTrace, String> {
  const StackTraceConverter();

  @override
  StackTrace fromJson(String json) => StackTrace.fromString(json);

  @override
  String toJson(StackTrace object) => object.toString();
}

@freezed
class AppError with _$AppError {
  const factory AppError({
    required String message,
    required ErrorType type,
    @StackTraceConverter() required StackTrace stackTrace,
    dynamic originalError,
  }) = _AppError;

  factory AppError.fromJson(Map<String, dynamic> json) =>
      _$AppErrorFromJson(json);

  const AppError._();

  String get userMessage {
    switch (type) {
      case ErrorType.network:
        return '網絡連接出現問題，請檢查網絡設置後重試';
      case ErrorType.validation:
        return '輸入的數據無效，請檢查後重試';
      case ErrorType.permission:
        return '沒有足夠的權限執行此操作';
      case ErrorType.server:
        return '服務器出現問題，請稍後重試';
      case ErrorType.unknown:
        return '發生未知錯誤，請重試';
    }
  }

  String get technicalMessage {
    return '''
錯誤類型: ${type.name}
錯誤信息: $message
原始錯誤: ${originalError?.toString() ?? '無'}
''';
  }
} 