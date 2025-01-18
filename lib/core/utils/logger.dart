import 'package:logger/logger.dart' as log;
import 'package:flutter/foundation.dart';

class Logger {
  final String _tag;

  Logger(this._tag);

  void info(String message) {
    print('[$_tag] INFO: $message');
  }

  void warning(String message) {
    print('[$_tag] WARNING: $message');
  }

  void error(String message) {
    print('[$_tag] ERROR: $message');
  }

  void debug(String message) {
    print('[$_tag] DEBUG: $message');
  }
} 