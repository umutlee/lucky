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
    _logger.d('[$_tag] $message', error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('[$_tag] $message', error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w('[$_tag] $message', error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[$_tag] $message', error, stackTrace);
  }

  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf('[$_tag] $message', error, stackTrace);
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