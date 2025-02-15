import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import 'dart:io';

final sqlitePreferencesServiceProvider = Provider<SQLitePreferencesService>((ref) {
  final logger = Logger('SQLitePreferencesService');
  return SQLitePreferencesService(logger);
});

class SQLitePreferencesService {
  final Logger _logger;
  late Database _db;

  SQLitePreferencesService(this._logger);

  Future<void> init() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, 'preferences.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS preferences (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        },
      );
      _logger.info('SQLitePreferencesService initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize SQLitePreferencesService', e);
      rethrow;
    }
  }

  Future<T?> getValue<T>(String key) async {
    try {
      final result = await _db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) {
        return null;
      }

      final value = result.first['value'] as String;
      return _parseValue<T>(value);
    } catch (e) {
      _logger.error('Failed to get value for key: $key', e);
      return null;
    }
  }

  Future<void> setValue<T>(String key, T value) async {
    try {
      final stringValue = _stringifyValue(value);
      await _db.insert(
        'preferences',
        {'key': key, 'value': stringValue},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _logger.error('Failed to set value for key: $key', e);
      rethrow;
    }
  }

  T? _parseValue<T>(String value) {
    try {
      if (T == bool) {
        return (value.toLowerCase() == 'true') as T;
      } else if (T == int) {
        return int.parse(value) as T;
      } else if (T == double) {
        return double.parse(value) as T;
      } else if (T == String) {
        return value as T;
      }
      return null;
    } catch (e) {
      _logger.error('Failed to parse value: $value to type $T', e);
      return null;
    }
  }

  String _stringifyValue<T>(T value) {
    return value.toString();
  }

  Future<void> clear() async {
    try {
      await _db.delete('preferences');
    } catch (e) {
      _logger.error('Failed to clear preferences', e);
      rethrow;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _db.delete(
        'preferences',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      _logger.error('Failed to remove key: $key', e);
      rethrow;
    }
  }
} 