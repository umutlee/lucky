import 'package:logger/logger.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  static void v(String message) {
    _instance._logger.v(message);
  }

  static void d(String message) {
    _instance._logger.d(message);
  }

  static void i(String message) {
    _instance._logger.i(message);
  }

  static void w(String message) {
    _instance._logger.w(message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance._logger.e(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.e(message);
    }
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance._logger.wtf(message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.wtf(message);
    }
  }

  static void log(Level level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _instance._logger.log(level, message, error: error, stackTrace: stackTrace);
    } else {
      _instance._logger.log(level, message);
    }
  }
} 