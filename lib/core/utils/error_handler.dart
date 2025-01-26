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
      return '網絡連接失敗\n請檢查：\n1. 網絡連接是否正常\n2. 行動數據或 Wi-Fi 是否開啟\n3. 是否處於飛行模式';
    }
    if (error is TimeoutException) {
      return '網絡請求超時\n建議：\n1. 檢查網絡連接速度\n2. 稍後重試\n3. 切換網絡連接方式';
    }
    return '網絡連接不穩定\n建議：\n1. 檢查網絡狀態\n2. 稍後重試';
  }

  /// 獲取數據庫錯誤信息
  static String _getDatabaseErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      switch (error.type) {
        case 'UNIQUE':
          return '該數據已存在\n請嘗試使用其他值';
        case 'NOT_NULL':
          return '必填資料未填寫\n請確保所有必填項都已填寫';
        case 'FOREIGN_KEY':
          return '關聯數據不存在\n請先創建相關數據';
        case 'TABLE_NOT_FOUND':
          return '數據表不存在\n請嘗試重新啟動應用';
        case 'COLUMN_NOT_FOUND':
          return '數據欄位不存在\n請更新到最新版本';
        default:
          return '數據存儲出現問題\n請稍後重試';
      }
    }
    return '數據操作失敗\n建議重新啟動應用';
  }

  /// 獲取驗證錯誤信息
  static String _getValidationErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      final messages = error.entries.map((e) => '• ${e.value}').join('\n');
      return '輸入資料有誤：\n$messages\n請檢查並修正以上問題';
    }
    return '輸入資料格式不正確\n請檢查並確保符合要求';
  }

  /// 獲取權限錯誤信息
  static String _getPermissionErrorMessage(dynamic error) {
    if (error is String) {
      return '無法獲取${error}權限\n請前往系統設置開啟相關權限';
    }
    return '權限不足\n請確保已授予應用所需權限';
  }

  /// 獲取業務邏輯錯誤信息
  static String _getBusinessErrorMessage(dynamic error) {
    if (error is String) {
      return '$error\n如有疑問請聯繫客服';
    }
    return '操作無法完成\n請確認操作步驟正確';
  }

  /// 獲取系統錯誤信息
  static String _getSystemErrorMessage(dynamic error) {
    if (error is Exception) {
      switch (error.runtimeType) {
        case FormatException:
          return '數據格式錯誤\n請確保輸入格式正確';
        case ArgumentError:
          return '參數錯誤\n請檢查輸入內容';
        case StateError:
          return '系統狀態異常\n請重新啟動應用';
        default:
          return '${error.toString()}\n請稍後重試';
      }
    }
    return '系統發生錯誤\n建議：\n1. 重新啟動應用\n2. 檢查網絡連接\n3. 更新到最新版本';
  }

  /// 處理網絡錯誤
  static void _handleNetworkError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('網絡錯誤'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              '需要幫助？',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            const Text('• 檢查 Wi-Fi 或行動數據是否開啟\n• 確認是否有網絡訊號\n• 嘗試切換網絡連接方式'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍後重試'),
          ),
          FilledButton.icon(
            onPressed: () {
              // TODO: 實現重試邏輯
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('立即重試'),
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
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('需要權限'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              '為什麼需要這個權限？',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            const Text('我們需要相關權限來提供完整的服務。您可以在系統設置中隨時更改權限設置。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('暫不設置'),
          ),
          FilledButton.icon(
            onPressed: () {
              // TODO: 打開應用設置頁面
              Navigator.pop(context);
            },
            icon: const Icon(Icons.settings),
            label: const Text('前往設置'),
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
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '了解',
          textColor: theme.colorScheme.onError,
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
            const SizedBox(height: 8),
            const Text(
              '如果問題持續存在，請嘗試：\n1. 重新整理頁面\n2. 重新啟動應用\n3. 檢查網絡連接',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
            const SizedBox(height: 8),
            const Text(
              '請檢查：\n1. 網絡連接是否正常\n2. 輸入內容是否正確\n3. 是否需要重新登入',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }
} 