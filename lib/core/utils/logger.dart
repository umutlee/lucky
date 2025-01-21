import 'package:flutter/foundation.dart';

class Logger {
  final String _tag;

  Logger(this._tag);

  void info(String message) {
    _log('INFO', message);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message);
    if (error != null) {
      _log('ERROR', '錯誤詳情: $error');
    }
    if (stackTrace != null) {
      _log('ERROR', '堆棧跟蹤: $stackTrace');
    }
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARNING', message);
    if (error != null) {
      _log('WARNING', '警告詳情: $error');
    }
    if (stackTrace != null) {
      _log('WARNING', '堆棧跟蹤: $stackTrace');
    }
  }

  void debug(String message) {
    if (kDebugMode) {
      _log('DEBUG', message);
    }
  }

  void _log(String level, String message) {
    if (kDebugMode) {
      print('[$level] $_tag: $message');
    }
  }
} 