import 'package:logging/logging.dart' as logging;

/// 日誌工具類,用於輸出不同級別的日誌信息
class Logger {
  static final Logger _instance = Logger._internal();
  final logging.Logger _logger;
  static bool debugMode = true;
  
  factory Logger() => _instance;
  
  Logger._internal() : _logger = logging.Logger('App');
  
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('INFO: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.info(message, error, stackTrace);
  }
  
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('WARNING: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.warning(message, error, stackTrace);
  }
  
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('ERROR: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.severe(message, error, stackTrace);
  }
  
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('DEBUG: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.fine(message, error, stackTrace);
  }
  
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('VERBOSE: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.finer(message, error, stackTrace);
  }
  
  void wtf(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('WTF: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.shout(message, error, stackTrace);
  }
  
  /// 靜態方法,用於直接輸出日誌
  static void log(String tag, String level, String message, {Object? error, StackTrace? stackTrace}) {
    if (debugMode) {
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