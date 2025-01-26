import 'package:flutter/material.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'dart:async';
import 'dart:io';

/// 自定義錯誤類型
enum ErrorType {
  network,     // 網絡錯誤
  database,    // 數據庫錯誤
  validation,  // 驗證錯誤
  permission,  // 權限錯誤
  business,    // 業務邏輯錯誤
  system,      // 系統錯誤
}

/// 自定義錯誤
class AppError implements Exception {
  final ErrorType type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError(
    this.type,
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// 錯誤處理器
class ErrorHandler {
  static final _logger = Logger('ErrorHandler');

  /// 處理錯誤
  static void handleError(
    BuildContext context,
    dynamic error, [
    StackTrace? stackTrace,
    String? friendlyMessage,
  ]) {
    _logger.error(friendlyMessage ?? '發生錯誤', error, stackTrace);

    final errorType = _getErrorType(error);
    final message = _getFriendlyMessage(error, friendlyMessage, errorType);
    
    switch (errorType) {
      case ErrorType.network:
        _handleNetworkError(context, message);
        break;
      case ErrorType.database:
        _handleDatabaseError(context, message);
        break;
      case ErrorType.permission:
        _handlePermissionError(context, message);
        break;
      case ErrorType.validation:
        _handleValidationError(context, message);
        break;
      default:
        _showErrorSnackBar(context, message);
    }
  }

  /// 獲取錯誤類型
  static ErrorType _getErrorType(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return ErrorType.network;
    }
    if (error is DatabaseException) {
      return ErrorType.database;
    }
    if (error is AppError) {
      return error.type;
    }
    return ErrorType.system;
  }

  /// 獲取友好錯誤信息
  static String _getFriendlyMessage(
    dynamic error,
    String? friendlyMessage,
    ErrorType type,
  ) {
    if (friendlyMessage != null) {
      return friendlyMessage;
    }

    if (error is AppError) {
      return error.message;
    }

    switch (type) {
      case ErrorType.network:
        return _getNetworkErrorMessage(error);
      case ErrorType.database:
        return _getDatabaseErrorMessage(error);
      case ErrorType.validation:
        return _getValidationErrorMessage(error);
      case ErrorType.permission:
        return _getPermissionErrorMessage(error);
      case ErrorType.business:
        return _getBusinessErrorMessage(error);
      case ErrorType.system:
        return _getSystemErrorMessage(error);
    }
  }

  /// 獲取網絡錯誤信息
  static String _getNetworkErrorMessage(dynamic error) {
    if (error is SocketException) {
      return '網絡連接失敗，請檢查網絡設置';
    }
    if (error is TimeoutException) {
      return '網絡請求超時，請稍後重試';
    }
    return '網絡錯誤，請稍後重試';
  }

  /// 獲取數據庫錯誤信息
  static String _getDatabaseErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      switch (error.type) {
        case 'UNIQUE':
          return '數據已存在';
        case 'NOT_NULL':
          return '必填數據不能為空';
        case 'FOREIGN_KEY':
          return '關聯數據不存在';
        default:
          return '數據庫操作失敗';
      }
    }
    return '數據存儲錯誤';
  }

  /// 獲取驗證錯誤信息
  static String _getValidationErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error.values.join('\n');
    }
    return '輸入數據無效';
  }

  /// 獲取權限錯誤信息
  static String _getPermissionErrorMessage(dynamic error) {
    if (error is String) {
      return '無法獲取$error權限';
    }
    return '權限不足';
  }

  /// 獲取業務邏輯錯誤信息
  static String _getBusinessErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    return '操作失敗';
  }

  /// 獲取系統錯誤信息
  static String _getSystemErrorMessage(dynamic error) {
    if (error is Exception) {
      switch (error.runtimeType) {
        case FormatException:
          return '數據格式錯誤';
        case ArgumentError:
          return '參數錯誤';
        case StateError:
          return '狀態錯誤';
        default:
          return error.toString();
      }
    }
    return '系統錯誤，請稍後重試';
  }

  /// 處理網絡錯誤
  static void _handleNetworkError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('網絡錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 實現重試邏輯
              Navigator.pop(context);
            },
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  /// 處理數據庫錯誤
  static void _handleDatabaseError(BuildContext context, String message) {
    _showErrorSnackBar(
      context,
      message,
      duration: const Duration(seconds: 5),
    );
  }

  /// 處理權限錯誤
  static void _handlePermissionError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('權限錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 打開應用設置頁面
              Navigator.pop(context);
            },
            child: const Text('去設置'),
          ),
        ],
      ),
    );
  }

  /// 處理驗證錯誤
  static void _handleValidationError(BuildContext context, String message) {
    _showErrorSnackBar(
      context,
      message,
      duration: const Duration(seconds: 3),
    );
  }

  /// 顯示錯誤提示
  static void _showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
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

  /// 錯誤提示組件
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

  /// 重試組件
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