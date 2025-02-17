import 'package:flutter/material.dart';

/// 錯誤視圖組件
class ErrorView extends StatelessWidget {
  /// 創建錯誤視圖組件
  const ErrorView({
    super.key,
    this.message = '載入失敗',
    this.onRetry,
  });

  /// 錯誤信息
  final String message;

  /// 重試回調
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('重試'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 