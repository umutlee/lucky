import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../utils/logger.dart';

final sqlitePreferencesServiceProvider = Provider<SQLitePreferencesService>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return SQLitePreferencesService(databaseHelper);
});

class SQLitePreferencesService {
  static const String _tag = 'SQLitePreferencesService';
  final _logger = Logger(_tag);
  final DatabaseHelper _databaseHelper;

  SQLitePreferencesService(DatabaseHelper databaseHelper) : _databaseHelper = databaseHelper;

  Future<bool> init() async {
    try {
      await _databaseHelper.init();
      
      // 檢查是否有任何偏好設置
      if (!await _hasAnyPreference()) {
        await _initializeDefaultValues();
      }
      
      return true;
    } catch (e, stackTrace) {
      _logger.error('SQLite 偏好設置服務初始化失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> setValue(String key, dynamic value) async {
    try {
      final data = {
        'key': key,
        'value': value.toString(),
        'type': value.runtimeType.toString(),
      };
      await _databaseHelper.insert('preferences', data);
      return true;
    } catch (e, stackTrace) {
      _logger.error('保存設置失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<T?> getValue<T>(String key, {T? defaultValue}) async {
    try {
      final result = await _databaseHelper.query(
        'preferences',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) {
        return defaultValue;
      }

      final value = result.first['value'] as String;
      return _convertValue<T>(value);
    } catch (e, stackTrace) {
      _logger.error('獲取設置失敗: $key', e, stackTrace);
      return defaultValue;
    }
  }

  Future<bool> remove(String key) async {
    try {
      final count = await _databaseHelper.delete(
        'preferences',
        where: 'key = ?',
        whereArgs: [key],
      );
      return count > 0;
    } catch (e, stackTrace) {
      _logger.error('刪除設置失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      await _databaseHelper.delete('preferences');
      await _initializeDefaultValues();
      return true;
    } catch (e, stackTrace) {
      _logger.error('清除設置失敗', e, stackTrace);
      return false;
    }
  }

  T? _convertValue<T>(String value) {
    switch (T) {
      case bool:
        return (value.toLowerCase() == 'true') as T?;
      case int:
        return int.tryParse(value) as T?;
      case double:
        return double.tryParse(value) as T?;
      case String:
        return value as T?;
      default:
        return null;
    }
  }

  Future<bool?> getDailyNotification() async {
    try {
      final result = await _databaseHelper.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['daily_notification'],
      );

      if (result.isEmpty) {
        return true; // 默認值
      }

      return result.first['value'] == 'true';
    } catch (e, stack) {
      _logger.error('獲取每日通知設置失敗', e, stack);
      return true; // 錯誤時返回默認值
    }
  }

  Future<String?> getNotificationTime() async {
    try {
      final result = await _databaseHelper.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['notification_time'],
      );

      if (result.isEmpty) {
        return '08:00'; // 默認值
      }

      return result.first['value'] as String;
    } catch (e, stack) {
      _logger.error('獲取通知時間設置失敗', e, stack);
      return '08:00'; // 錯誤時返回默認值
    }
  }

  Future<void> setDailyNotification(bool enabled) async {
    try {
      await _databaseHelper.insert(
        'preferences',
        {
          'key': 'daily_notification',
          'value': enabled.toString(),
          'type': 'bool',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      _logger.error('設置每日通知失敗', e, stack);
      rethrow;
    }
  }

  Future<void> setNotificationTime(String time) async {
    try {
      await _databaseHelper.insert(
        'preferences',
        {
          'key': 'notification_time',
          'value': time,
          'type': 'string',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      _logger.error('設置通知時間失敗', e, stack);
      rethrow;
    }
  }

  Future<bool> _hasAnyPreference() async {
    final result = await _databaseHelper.query('preferences', limit: 1);
    return result.isNotEmpty;
  }

  Future<void> _initializeDefaultValues() async {
    try {
      await Future.wait([
        setDailyNotification(true),
        setNotificationTime('09:00'),
      ]);
      _logger.info('默認偏好設置初始化成功');
    } catch (e, stack) {
      _logger.error('初始化默認偏好設置失敗', e, stack);
      rethrow;
    }
  }

  Future<List<String>> getKeys() async {
    try {
      final result = await _databaseHelper.query('preferences', columns: ['key']);
      return result.map((row) => row['key'] as String).toList();
    } catch (e) {
      _logger.error('Failed to get keys', e);
      return [];
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      final result = await _databaseHelper.query(
        'preferences',
        columns: ['key'],
        where: 'key = ?',
        whereArgs: [key],
      );
      return result.isNotEmpty;
    } catch (e) {
      _logger.error('Failed to check key existence', e);
      return false;
    }
  }
} 