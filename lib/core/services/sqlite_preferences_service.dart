import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../utils/logger.dart';

final sqlitePreferencesServiceProvider = Provider<SQLitePreferencesService>((ref) {
  return SQLitePreferencesService(ref.read(databaseHelperProvider));
});

class SQLitePreferencesService {
  static const String _tableName = 'preferences';
  static const String _keyDailyNotification = 'daily_notification';
  static const String _keyNotificationTime = 'notification_time';
  
  final DatabaseHelper _db;
  final _logger = Logger('SQLitePreferencesService');

  SQLitePreferencesService(this._db);

  Future<void> init() async {
    try {
      // 檢查是否需要初始化默認值
      final hasDefaultValues = await _hasAnyPreference();
      if (!hasDefaultValues) {
        await _initializeDefaultValues();
      }
      _logger.info('偏好設置服務初始化成功');
    } catch (e, stack) {
      _logger.error('偏好設置服務初始化失敗', e, stack);
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

  Future<void> setDailyNotification(bool enabled) async {
    try {
      await _db.insert(
        _tableName,
        {
          'key': _keyDailyNotification,
          'value': enabled.toString(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.info('每日通知設置已更新: $enabled');
    } catch (e, stack) {
      _logger.error('設置每日通知失敗', e, stack);
      rethrow;
    }
  }

  Future<void> setNotificationTime(String time) async {
    try {
      await _db.insert(
        _tableName,
        {
          'key': _keyNotificationTime,
          'value': time,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.info('通知時間已更新: $time');
    } catch (e, stack) {
      _logger.error('設置通知時間失敗', e, stack);
      rethrow;
    }
  }

  Future<bool> getDailyNotification() async {
    try {
      final result = await _db.query(
        _tableName,
        where: 'key = ?',
        whereArgs: [_keyDailyNotification],
      );
      
      if (result.isEmpty) {
        return true; // 默認值
      }
      
      return result.first['value'] == 'true';
    } catch (e, stack) {
      _logger.error('獲取每日通知設置失敗', e, stack);
      return true; // 發生錯誤時返回默認值
    }
  }

  Future<String> getNotificationTime() async {
    try {
      final result = await _db.query(
        _tableName,
        where: 'key = ?',
        whereArgs: [_keyNotificationTime],
      );
      
      if (result.isEmpty) {
        return '08:00'; // 默認值
      }
      
      return result.first['value'] as String;
    } catch (e, stack) {
      _logger.error('獲取通知時間失敗', e, stack);
      return '08:00'; // 發生錯誤時返回默認值
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