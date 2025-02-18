import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/app_error.dart';

final errorServiceProvider = Provider<ErrorService>((ref) {
  final logger = Logger('ErrorService');
  return ErrorService(logger);
});

class ErrorService {
  final Logger _logger;

  ErrorService(this._logger);

  AppError handleError(Object error, StackTrace stackTrace) {
    if (error is DioException) {
      return _handleDioError(error, stackTrace);
    } else if (error is SocketException) {
      return AppError(
        message: '網路連接錯誤',
        type: ErrorType.network,
        stackTrace: stackTrace,
      );
    } else if (error is FormatException) {
      return AppError(
        message: '數據格式錯誤',
        type: ErrorType.validation,
        stackTrace: stackTrace,
      );
    } else {
      return AppError(
        message: error.toString(),
        type: ErrorType.unknown,
        stackTrace: stackTrace,
      );
    }
  }

  AppError _handleDioError(DioException error, StackTrace stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: '連接超時',
          type: ErrorType.network,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String? ?? '未知錯誤';
        return AppError(
          message: message,
          type: ErrorType.server,
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return AppError(
          message: '請求已取消',
          type: ErrorType.unknown,
          stackTrace: stackTrace,
        );
      default:
        return AppError(
          message: '網路錯誤',
          type: ErrorType.network,
          stackTrace: stackTrace,
        );
    }
  }

  void showError(BuildContext context, AppError error) {
    _logger.error('顯示錯誤給用戶: ${error.message}');

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
    _logger.error('顯示錯誤對話框給用戶: ${error.message}');

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