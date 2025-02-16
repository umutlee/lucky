import 'package:logging/logging.dart' as logging;

/// 日誌工具類,用於輸出不同級別的日誌信息
class Logger {
  static final Logger _instance = Logger._internal('');
  final logging.Logger _logger;
  final String _tag;
  static bool debugMode = true;
  
  factory Logger([String tag = '']) => Logger._internal(tag);
  
  Logger._internal(this._tag) : _logger = logging.Logger('AllLucky');
  
  void info(String message) {
    if (debugMode) {
      print('INFO: $_tag $message');
    }
    _logger.info('[$_tag] $message');
  }
  
  void warning(String message, [Object? error]) {
    if (debugMode) {
      print('WARNING: $_tag $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
    _logger.warning('[$_tag] $message', error);
  }
  
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('ERROR: $_tag $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.severe('[$_tag] $message', error, stackTrace);
  }
  
  void debug(String message) {
    if (debugMode) {
      print('DEBUG: $_tag $message');
    }
    _logger.fine('[$_tag] $message');
  }
  
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('VERBOSE: $_tag $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.finer('[$_tag] $message', error, stackTrace);
  }
  
  void wtf(String message, [Object? error, StackTrace? stackTrace]) {
    if (debugMode) {
      print('WTF: $_tag $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
    _logger.shout('[$_tag] $message', error, stackTrace);
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