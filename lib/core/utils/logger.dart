import 'package:logger/logger.dart' as log;

class Logger {
  final String _tag;
  late final log.Logger _logger;

  Logger(this._tag) {
    _logger = log.Logger(
      printer: log.PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d('[$_tag] $message');
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('[$_tag] $message');
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w('[$_tag] $message');
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[$_tag] $message');
  }

  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf('[$_tag] $message');
  }
} 