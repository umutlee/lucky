import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'logger_service.dart';

part 'error_service.freezed.dart';
part 'error_service.g.dart';

class StackTraceConverter implements JsonConverter<StackTrace?, String?> {
  const StackTraceConverter();

  @override
  StackTrace? fromJson(String? json) {
    if (json == null) return null;
    return StackTrace.fromString(json);
  }

  @override
  String? toJson(StackTrace? stackTrace) {
    if (stackTrace == null) return null;
    return stackTrace.toString();
  }
}

class ObjectConverter implements JsonConverter<Object?, String?> {
  const ObjectConverter();

  @override
  Object? fromJson(String? json) {
    if (json == null) return null;
    return json;
  }

  @override
  String? toJson(Object? object) {
    if (object == null) return null;
    return object.toString();
  }
}

enum ErrorType {
  network,    // 網絡錯誤
  validation, // 數據驗證錯誤
  permission, // 權限錯誤
  server,     // 服務器錯誤
  unknown     // 未知錯誤
}

@freezed
class AppError with _$AppError {
  const factory AppError({
    required String message,
    required ErrorType type,
    @ObjectConverter() Object? originalError,
    @StackTraceConverter() StackTrace? stackTrace,
  }) = _AppError;

  factory AppError.fromJson(Map<String, dynamic> json) => _$AppErrorFromJson(json);

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

final errorServiceProvider = Provider<ErrorService>((ref) {
  final logger = ref.watch(loggerProvider);
  return ErrorService(logger);
});

class ErrorService {
  final LoggerService _logger;

  ErrorService(this._logger);

  AppError handleError(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      _logger.error(
        'AppError occurred',
        error,
        stackTrace,
      );
      return error;
    }

    AppError appError;

    // 網絡錯誤
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      appError = AppError(
        message: '網絡連接失敗',
        type: ErrorType.network,
        originalError: error,
        stackTrace: stackTrace,
      );
      _logger.error(
        'Network error occurred',
        error,
        stackTrace,
      );
    }
    // 權限錯誤
    else if (error.toString().contains('Permission') ||
        error.toString().contains('Unauthorized')) {
      appError = AppError(
        message: '權限不足',
        type: ErrorType.permission,
        originalError: error,
        stackTrace: stackTrace,
      );
      _logger.error(
        'Permission error occurred',
        error,
        stackTrace,
      );
    }
    // 服務器錯誤
    else if (error.toString().contains('Server') ||
        error.toString().contains('500')) {
      appError = AppError(
        message: '服務器錯誤',
        type: ErrorType.server,
        originalError: error,
        stackTrace: stackTrace,
      );
      _logger.error(
        'Server error occurred',
        error,
        stackTrace,
      );
    }
    // 默認為未知錯誤
    else {
      appError = AppError(
        message: error.toString(),
        type: ErrorType.unknown,
        originalError: error,
        stackTrace: stackTrace,
      );
      _logger.error(
        'Unknown error occurred',
        error,
        stackTrace,
      );
    }

    return appError;
  }

  void showError(BuildContext context, AppError error) {
    _logger.warning(
      'Showing error to user: ${error.userMessage}',
      error.originalError,
      error.stackTrace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userMessage),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '確定',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> showErrorDialog(BuildContext context, AppError error) async {
    _logger.warning(
      'Showing error dialog to user: ${error.userMessage}',
      error.originalError,
      error.stackTrace,
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, size: 48),
        title: const Text('錯誤'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.userMessage),
            const SizedBox(height: 8),
            if (error.stackTrace != null) ...[
              const Divider(),
              Text(
                '技術詳情',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error.technicalMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}