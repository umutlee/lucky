import 'dart:async';
import 'package:flutter/foundation.dart';

/// 重試函數,用於處理可能失敗的異步操作
Future<T> retry<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
  bool Function(Exception)? shouldRetry,
}) async {
  int attempts = 0;
  
  while (true) {
    try {
      attempts++;
      return await fn();
    } on Exception catch (e) {
      if (attempts >= maxAttempts || 
          (shouldRetry != null && !shouldRetry(e))) {
        rethrow;
      }
      
      if (kDebugMode) {
        print('Retry attempt $attempts failed: $e');
        print('Retrying in ${delay.inSeconds} seconds...');
      }
      
      await Future.delayed(delay);
    }
  }
} 