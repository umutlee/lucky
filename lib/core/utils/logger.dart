import 'package:logger/logger.dart' as log;
import 'package:flutter/foundation.dart';

class Logger {
  final String _tag;
  late final log.Logger _logger;

  static final Map<String, Logger> _cache = {};

  factory Logger(String tag) {
    return _cache.putIfAbsent(tag, () => Logger._internal(tag));
  }

  Logger._internal(this._tag) {
    _logger = log.Logger(
      printer: _CustomPrinter(_tag),
      level: kDebugMode ? log.Level.verbose : log.Level.warning,
    );
  }

  void verbose(String message) {
    _logger.v(message);
  }

  void debug(String message) {
    _logger.d(message);
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}

class _CustomPrinter extends log.PretterPrinter {
  final String _tag;

  _CustomPrinter(this._tag) : super(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  );

  @override
  List<String> log(log.LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error?.toString();
    var timeStr = DateTime.now().toIso8601String();

    return [
      '[$timeStr] $_tag: $messageStr${errorStr != null ? ' - $errorStr' : ''}',
      if (event.stackTrace != null) event.stackTrace.toString(),
    ];
  }

  String _stringifyMessage(dynamic message) {
    if (message is Function) return message();
    if (message is String) return message;
    return message.toString();
  }
} 