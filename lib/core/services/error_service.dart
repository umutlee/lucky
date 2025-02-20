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

  Future<AppError> handleError(dynamic error, [StackTrace? stackTrace]) async {
    if (error is AppError) {
      return error;
    }

    if (error is Exception) {
      if (error.toString().contains('SocketException') ||
          error.toString().contains('TimeoutException') ||
          error.toString().contains('NetworkException')) {
        return AppError(
          message: '網絡連接出現問題，請檢查網絡設置後重試',
          type: ErrorType.network,
          stackTrace: stackTrace ?? StackTrace.current,
        );
      }

      if (error.toString().contains('ValidationException')) {
        return AppError(
          message: '輸入的數據無效，請檢查後重試',
          type: ErrorType.validation,
          stackTrace: stackTrace ?? StackTrace.current,
        );
      }
    }

    return AppError(
      message: '發生未知錯誤，請重試',
      type: ErrorType.unknown,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  Future<AppError> handleNetworkError(dynamic error, [StackTrace? stackTrace]) async {
    if (error is AppError) {
      return error;
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return AppError(
        message: '網絡連接出現問題，請檢查網絡設置後重試',
        type: ErrorType.network,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }

    if (error.toString().contains('ServerException') ||
        error.toString().contains('500')) {
      return AppError(
        message: '服務器出現問題，請稍後重試',
        type: ErrorType.server,
        stackTrace: stackTrace ?? StackTrace.current,
      );
    }

    return AppError(
      message: '發生未知錯誤，請重試',
      type: ErrorType.unknown,
      stackTrace: stackTrace ?? StackTrace.current,
    );
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