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

  SQLitePreferencesService(this._databaseHelper);

  Future<bool> init() async {
    try {
      await _databaseHelper.init();
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
      final db = await _databaseHelper.database;
      final result = await db.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['notification_enabled'],
      );

      if (result.isEmpty) {
        return null;
      }

      return result.first['value'] == '1';
    } catch (e, stack) {
      _logger.error('獲取每日通知設置失敗', e, stack);
      return null;
    }
  }

  Future<String?> getNotificationTime() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['notification_time'],
      );

      if (result.isEmpty) {
        return null;
      }

      return result.first['value'] as String?;
    } catch (e, stack) {
      _logger.error('獲取通知時間設置失敗', e, stack);
      return null;
    }
  }

  Future<void> setDailyNotification(bool enabled) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'preferences',
        {
          'key': 'notification_enabled',
          'value': enabled ? '1' : '0',
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
      final db = await _databaseHelper.database;
      await db.insert(
        'preferences',
        {
          'key': 'notification_time',
          'value': time,
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
        setNotificationTime('08:00'),
      ]);
      _logger.info('默認偏好設置初始化成功');
    } catch (e, stack) {
      _logger.error('初始化默認偏好設置失敗', e, stack);
      rethrow;
    }
  }

  // 遷移數據方法
  Future<bool> migrateFromSharedPreferences(Map<String, dynamic> oldData) async {
    try {
      // 開始事務
      await _databaseHelper.database.then((db) async {
        await db.transaction((txn) async {
          // 清空現有數據
          await txn.delete('preferences');
          
          // 插入舊數據
          for (var entry in oldData.entries) {
            await txn.insert(
              'preferences',
              {
                'key': entry.key,
                'value': entry.value.toString(),
                'updated_at': DateTime.now().toIso8601String(),
              },
            );
          }
        });
      });
      
      _logger.info('從 SharedPreferences 遷移數據成功');
      return true;
    } catch (e, stack) {
      _logger.error('從 SharedPreferences 遷移數據失敗', e, stack);
      return false;
    }
  }
} 