import 'package:flutter/material.dart';
import 'package:all_lucky/core/utils/logger.dart';

class ErrorHandler {
  static final _logger = Logger('ErrorHandler');

  static void handleError(
    BuildContext context,
    dynamic error, [
    StackTrace? stackTrace,
    String? friendlyMessage,
  ]) {
    _logger.error(friendlyMessage ?? '發生錯誤', error, stackTrace);

    String message = _getFriendlyMessage(error, friendlyMessage);
    _showErrorSnackBar(context, message);
  }

  static String _getFriendlyMessage(dynamic error, String? friendlyMessage) {
    if (friendlyMessage != null) {
      return friendlyMessage;
    }

    if (error is Exception) {
      return _getExceptionMessage(error);
    }

    return '發生未知錯誤，請稍後再試';
  }

  static String _getExceptionMessage(Exception error) {
    switch (error.runtimeType) {
      case FormatException:
        return '數據格式錯誤';
      case ArgumentError:
        return '參數錯誤';
      case StateError:
        return '狀態錯誤';
      case TimeoutException:
        return '操作超時，請檢查網絡連接';
      default:
        return error.toString();
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '確定',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static Widget errorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget retryWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 48,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }
} 