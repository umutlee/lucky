import 'package:logger/logger.dart' as log;

class AppLogger {
  static final Logger _logger = Logger(
    printer: log.PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }
}

// 擴展 Logger 類以支持更多功能
extension LoggerExtension on Logger {
  void logApiCall(String endpoint, {
    dynamic request,
    dynamic response,
    Duration? duration,
    String? method,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('API Call:');
    buffer.writeln('Endpoint: $endpoint');
    if (method != null) buffer.writeln('Method: $method');
    if (duration != null) buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    if (request != null) buffer.writeln('Request: $request');
    if (response != null) buffer.writeln('Response: $response');
    
    i(buffer.toString());
  }

  void logError(String message, dynamic error, StackTrace stackTrace, {
    String? context,
    Map<String, dynamic>? extra,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Error:');
    if (context != null) buffer.writeln('Context: $context');
    buffer.writeln('Message: $message');
    if (extra != null) {
      buffer.writeln('Extra Info:');
      extra.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    e(buffer.toString(), error, stackTrace);
  }

  void logEvent(String eventName, {
    Map<String, dynamic>? parameters,
    String? userId,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Event: $eventName');
    if (userId != null) buffer.writeln('User ID: $userId');
    if (parameters != null) {
      buffer.writeln('Parameters:');
      parameters.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    i(buffer.toString());
  }

  void logNavigation(String routeName, {
    Map<String, dynamic>? arguments,
    String? previousRoute,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Navigation:');
    buffer.writeln('Route: $routeName');
    if (previousRoute != null) buffer.writeln('From: $previousRoute');
    if (arguments != null) {
      buffer.writeln('Arguments:');
      arguments.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    d(buffer.toString());
  }

  void logPerformance(String operation, Duration duration, {
    Map<String, dynamic>? metrics,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Performance:');
    buffer.writeln('Operation: $operation');
    buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    if (metrics != null) {
      buffer.writeln('Metrics:');
      metrics.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }
    
    i(buffer.toString());
  }
} 