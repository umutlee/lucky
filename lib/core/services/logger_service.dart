import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error;

  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

final loggerProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});

class LoggerService {
  static const String _logFileName = 'app.log';
  static const int _maxLogFiles = 5;
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  Future<File> get _logFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_logFileName');
  }

  Future<void> _rotateLogFiles() async {
    final file = await _logFile;
    if (!await file.exists()) return;

    final fileSize = await file.length();
    if (fileSize < _maxFileSizeBytes) return;

    // 刪除最舊的日誌文件
    for (var i = _maxLogFiles - 1; i >= 0; i--) {
      final oldFile = File('${file.path}.$i');
      if (await oldFile.exists()) {
        if (i == _maxLogFiles - 1) {
          await oldFile.delete();
        } else {
          await oldFile.rename('${file.path}.${i + 1}');
        }
      }
    }

    // 重命名當前日誌文件
    await file.rename('${file.path}.0');
  }

  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logMessage = StringBuffer()
      ..writeln('[$timestamp] ${level.emoji} ${level.name}: $message');

    if (error != null) {
      logMessage.writeln('Error: $error');
    }

    if (stackTrace != null) {
      logMessage.writeln('StackTrace:\n$stackTrace');
    }

    logMessage.writeln('-' * 80);

    // 輸出到控制台
    print(logMessage);

    // 寫入文件
    try {
      await _rotateLogFiles();
      final file = await _logFile;
      await file.writeAsString(
        logMessage.toString(),
        mode: FileMode.append,
      );
    } catch (e) {
      print('Failed to write log to file: $e');
    }
  }

  Future<String> getLogContent() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print('Failed to read log file: $e');
    }
    return '';
  }

  Future<void> clearLogs() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Failed to clear logs: $e');
    }
  }

  // 用於開發調試的方法
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, level: LogLevel.debug, error: error, stackTrace: stackTrace);
  }

  // 用於一般信息記錄
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, level: LogLevel.info, error: error, stackTrace: stackTrace);
  }

  // 用於警告信息記錄
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, level: LogLevel.warning, error: error, stackTrace: stackTrace);
  }

  // 用於錯誤信息記錄
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  }
} 