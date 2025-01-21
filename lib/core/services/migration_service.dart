import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'sqlite_preferences_service.dart';
import 'sqlite_user_settings_service.dart';

final migrationServiceProvider = Provider<MigrationService>((ref) {
  return MigrationService(
    ref.read(sqlitePreferencesServiceProvider),
    ref.read(sqliteUserSettingsServiceProvider),
  );
});

class MigrationService {
  static const String _migrationCompleteKey = 'sqlite_migration_complete';
  
  final SQLitePreferencesService _preferencesService;
  final SQLiteUserSettingsService _userSettingsService;
  final _logger = Logger('MigrationService');

  MigrationService(this._preferencesService, this._userSettingsService);

  Future<bool> needsMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_migrationCompleteKey) ?? false);
    } catch (e, stack) {
      _logger.error('檢查遷移狀態失敗', e, stack);
      return false;
    }
  }

  Future<void> migrateToSQLite() async {
    try {
      _logger.info('開始數據遷移');
      
      final prefs = await SharedPreferences.getInstance();
      
      // 遷移偏好設置
      final preferencesData = {
        'daily_notification': prefs.getBool('daily_notification'),
        'notification_time': prefs.getString('notification_time'),
      };
      
      await _preferencesService.migrateFromSharedPreferences(
        Map.fromEntries(
          preferencesData.entries.where((e) => e.value != null),
        ),
      );

      // 遷移用戶設置
      final userSettingsJson = prefs.getString('user_settings');
      if (userSettingsJson != null) {
        await _userSettingsService.migrateFromSharedPreferences(userSettingsJson);
      }

      // 標記遷移完成
      await prefs.setBool(_migrationCompleteKey, true);
      
      _logger.info('數據遷移完成');
    } catch (e, stack) {
      _logger.error('數據遷移失敗', e, stack);
      rethrow;
    }
  }

  Future<void> rollbackMigration() async {
    try {
      _logger.info('開始回滾遷移');
      
      final prefs = await SharedPreferences.getInstance();
      
      // 移除遷移完成標記
      await prefs.remove(_migrationCompleteKey);
      
      _logger.info('遷移回滾完成');
    } catch (e, stack) {
      _logger.error('遷移回滾失敗', e, stack);
      rethrow;
    }
  }

  Future<void> cleanupOldData() async {
    try {
      _logger.info('開始清理舊數據');
      
      final prefs = await SharedPreferences.getInstance();
      
      // 清理舊的偏好設置
      await prefs.remove('daily_notification');
      await prefs.remove('notification_time');
      
      // 清理舊的用戶設置
      await prefs.remove('user_settings');
      
      _logger.info('舊數據清理完成');
    } catch (e, stack) {
      _logger.error('清理舊數據失敗', e, stack);
      rethrow;
    }
  }
} 