import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/backup_service.dart';
import 'package:all_lucky/core/services/sqlite_preferences_service.dart';
import 'package:all_lucky/core/services/sqlite_user_settings_service.dart';
import 'package:all_lucky/core/utils/logger.dart';

final migrationServiceProvider = Provider<MigrationService>((ref) {
  return MigrationService(
    ref.read(sqlitePreferencesServiceProvider),
    ref.read(sqliteUserSettingsServiceProvider),
  );
});

/// 數據遷移狀態
enum MigrationState {
  /// 未開始
  notStarted,
  
  /// 進行中
  inProgress,
  
  /// 已完成
  completed,
  
  /// 失敗
  failed,
  
  /// 已回滾
  rolledBack
}

/// 數據遷移服務
class MigrationService {
  final SQLitePreferencesService _preferencesService;
  final SQLiteUserSettingsService _userSettingsService;
  final _logger = Logger('MigrationService');

  MigrationService(this._preferencesService, this._userSettingsService);

  /// 檢查是否需要遷移
  Future<bool> needsMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey('migration_complete');
    } catch (e, stack) {
      _logger.error('檢查遷移狀態失敗', e, stack);
      return false;
    }
  }
  
  /// 執行數據遷移
  Future<void> migrateToSQLite() async {
    try {
      _logger.info('開始數據遷移');
      
      final prefs = await SharedPreferences.getInstance();
      
      // 遷移通知設置
      final hasNotification = prefs.getBool('daily_notification') ?? false;
      final notificationTime = prefs.getString('notification_time') ?? '08:00';
      
      await _preferencesService.setDailyNotification(hasNotification);
      await _preferencesService.setNotificationTime(notificationTime);
      
      // 標記遷移完成
      await prefs.setBool('migration_complete', true);
      
      _logger.info('數據遷移完成');
    } catch (e, stack) {
      _logger.error('數據遷移失敗', e, stack);
      rethrow;
    }
  }
  
  /// 回滾遷移
  Future<void> rollbackMigration() async {
    try {
      _logger.info('開始回滾遷移');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('migration_complete');
      
      // 清理 SQLite 數據
      await _preferencesService.clear();
      await _userSettingsService.clear();
      
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
      await prefs.remove('daily_notification');
      await prefs.remove('notification_time');
      
      _logger.info('舊數據清理完成');
    } catch (e, stack) {
      _logger.error('清理舊數據失敗', e, stack);
      rethrow;
    }
  }
} 