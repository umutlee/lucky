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
  
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.i('[$_tag] $message', error, stackTrace);
  }
  
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e('[$_tag] $message', error, stackTrace);
  }
  
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.w('[$_tag] $message', error, stackTrace);
  }
  
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.d('[$_tag] $message', error, stackTrace);
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