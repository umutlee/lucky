import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../utils/logger.dart';

final sqlitePreferencesServiceProvider = Provider<SQLitePreferencesService>((ref) {
  return SQLitePreferencesService(
    ref.read(databaseHelperProvider),
  );
});

class SQLitePreferencesService {
  final DatabaseHelper _db;
  final _logger = Logger('SQLitePreferencesService');
  static const _tableName = 'preferences';

  SQLitePreferencesService(this._db);

  Future<void> init() async {
    try {
      await _db.init();
    } catch (e, stack) {
      _logger.error('初始化 SQLite 偏好設置服務失敗', e, stack);
      rethrow;
    }
  }

  Future<bool?> getDailyNotification() async {
    try {
      final db = await _db.database;
      final result = await db.query(
        _tableName,
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
      final db = await _db.database;
      final result = await db.query(
        _tableName,
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
      final db = await _db.database;
      await db.insert(
        _tableName,
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
      final db = await _db.database;
      await db.insert(
        _tableName,
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
    final result = await _db.query(_tableName, limit: 1);
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

  Future<void> clear() async {
    try {
      await _db.delete(_tableName);
      _logger.info('偏好設置已清空');
    } catch (e, stack) {
      _logger.error('清空偏好設置失敗', e, stack);
      rethrow;
    }
  }

  // 遷移數據方法
  Future<void> migrateFromSharedPreferences(Map<String, dynamic> oldData) async {
    try {
      // 開始事務
      await _db.database.then((db) async {
        await db.transaction((txn) async {
          // 清空現有數據
          await txn.delete(_tableName);
          
          // 插入舊數據
          for (var entry in oldData.entries) {
            await txn.insert(
              _tableName,
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
    } catch (e, stack) {
      _logger.error('從 SharedPreferences 遷移數據失敗', e, stack);
      rethrow;
    }
  }
} 