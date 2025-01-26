import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日誌工具類,用於輸出不同級別的日誌信息
class Logger {
  final String _tag;
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  Logger(this._tag);
  
  void info(String message) {
    if (kDebugMode) {
      print('[$_tag] INFO: $message');
    }
  }
  
  void warning(String message) {
    if (kDebugMode) {
      print('[$_tag] WARNING: $message');
    }
  }
  
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$_tag] ERROR: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
  }
  
  void debug(String message) {
    if (kDebugMode) {
      print('[$_tag] DEBUG: $message');
    }
  }
  
  void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.v('[$_tag] $message', error, stackTrace);
  }
  
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.wtf('[$_tag] $message', error, stackTrace);
  }
  
  /// 靜態方法,用於直接輸出日誌
  static void log(String tag, String level, String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[$level] $tag: $message');
      if (error != null) {
        print('[$level] $tag: 錯誤詳情: $error');
      }
      if (stackTrace != null) {
        print('[$level] $tag: 堆棧跟蹤: $stackTrace');
      }
    }
  }
  
  static void i(String tag, String message) {
    log(tag, 'INFO', message);
  }
  
  static void e(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    log(tag, 'ERROR', message, error: error, stackTrace: stackTrace);
  }
  
  static void w(String tag, String message) {
    log(tag, 'WARNING', message);
  }
  
  static void d(String tag, String message) {
    log(tag, 'DEBUG', message);
  }
} 