import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/backup_service.dart';
import 'package:all_lucky/core/services/sqlite_preferences_service.dart';
import 'package:all_lucky/core/services/sqlite_user_settings_service.dart';
import 'package:all_lucky/core/utils/logger.dart';

final migrationServiceProvider = Provider<MigrationService>((ref) {
  final backupService = ref.watch(backupServiceProvider);
  final sqlitePrefs = ref.watch(sqlitePreferencesServiceProvider);
  final sqliteUserSettings = ref.watch(sqliteUserSettingsServiceProvider);
  return MigrationService(
    backupService: backupService,
    sqlitePrefs: sqlitePrefs,
    sqliteUserSettings: sqliteUserSettings,
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
  static const String _tag = 'MigrationService';
  final _logger = Logger(_tag);
  static const String _migrationCompleteKey = 'migration_complete';
  
  final BackupService _backupService;
  final SQLitePreferencesService _sqlitePrefs;
  final SQLiteUserSettingsService _sqliteUserSettings;
  
  MigrationService({
    required BackupService backupService,
    required SQLitePreferencesService sqlitePrefs,
    required SQLiteUserSettingsService sqliteUserSettings,
  })  : _backupService = backupService,
        _sqlitePrefs = sqlitePrefs,
        _sqliteUserSettings = sqliteUserSettings;
  
  /// 檢查是否需要遷移
  Future<bool> needsMigration() async {
    try {
      await _initializeServices();
      final migrationComplete = await _sqlitePrefs.getValue<bool>(_migrationCompleteKey) ?? false;
      return !migrationComplete;
    } catch (e, stackTrace) {
      _logger.error('檢查遷移狀態失敗', e, stackTrace);
      return true;
    }
  }
  
  /// 執行數據遷移
  Future<bool> migrateToSQLite() async {
    try {
      _logger.info('開始數據遷移');
      
      // 創建備份
      if (!await _backupService.createBackup()) {
        throw Exception('創建備份失敗');
      }
      
      // 初始化 SQLite 服務
      if (!await _initializeServices()) {
        throw Exception('初始化 SQLite 服務失敗');
      }
      
      // 執行遷移
      if (!await _migrateData()) {
        throw Exception('遷移數據失敗');
      }
      
      // 驗證遷移結果
      if (!await _validateMigration()) {
        throw Exception('驗證遷移結果失敗');
      }
      
      // 標記遷移完成
      await _sqlitePrefs.setValue(_migrationCompleteKey, true);
      
      _logger.info('數據遷移完成');
      return true;
    } catch (e, stackTrace) {
      _logger.error('數據遷移過程中發生錯誤', e, stackTrace);
      await _rollback();
      return false;
    }
  }
  
  /// 初始化 SQLite 服務
  Future<bool> _initializeServices() async {
    try {
      final prefsInitialized = await _sqlitePrefs.init();
      final userSettingsInitialized = await _sqliteUserSettings.init();
      
      if (!prefsInitialized || !userSettingsInitialized) {
        throw Exception('服務初始化失敗');
      }
      
      return true;
    } catch (e, stackTrace) {
      _logger.error('初始化 SQLite 服務失敗', e, stackTrace);
      return false;
    }
  }
  
  /// 遷移數據到 SQLite
  Future<bool> _migrateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldData = {
        'test_key': prefs.getString('test_key'),
        'test_bool': prefs.getBool('test_bool'),
        'test_int': prefs.getInt('test_int'),
        'migration_complete': prefs.getBool('migration_complete'),
        'zodiac': prefs.getInt('zodiac'),
        'birth_year': prefs.getInt('birth_year'),
        'notifications_enabled': prefs.getBool('notifications_enabled'),
        'location_permission_granted': prefs.getBool('location_permission_granted'),
        'onboarding_completed': prefs.getBool('onboarding_completed'),
        'terms_accepted': prefs.getBool('terms_accepted'),
        'privacy_accepted': prefs.getBool('privacy_accepted'),
      };

      final prefsSuccess = await _sqlitePrefs.migrateFromSharedPreferences(oldData);
      if (!prefsSuccess) {
        _logger.error('遷移數據失敗');
        return false;
      }

      final userSettingsSuccess = await _sqliteUserSettings.migrateFromSharedPreferences(oldData);
      if (!userSettingsSuccess) {
        _logger.error('遷移用戶設置失敗');
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      _logger.error('遷移數據失敗', e, stackTrace);
      return false;
    }
  }
  
  /// 驗證遷移結果
  Future<bool> _validateMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldData = {
        'test_key': prefs.getString('test_key'),
        'test_bool': prefs.getBool('test_bool'),
        'test_int': prefs.getInt('test_int'),
        'migration_complete': prefs.getBool('migration_complete'),
        'zodiac': prefs.getInt('zodiac'),
        'birth_year': prefs.getInt('birth_year'),
        'notifications_enabled': prefs.getBool('notifications_enabled'),
        'location_permission_granted': prefs.getBool('location_permission_granted'),
        'onboarding_completed': prefs.getBool('onboarding_completed'),
        'terms_accepted': prefs.getBool('terms_accepted'),
        'privacy_accepted': prefs.getBool('privacy_accepted'),
      };

      // 驗證偏好設置
      final prefsValue = await _sqlitePrefs.getValue<String>('test_key');
      if (prefsValue != oldData['test_key']) {
        _logger.error('驗證遷移結果失敗: 偏好設置不匹配');
        return false;
      }

      // 驗證用戶設置
      final userSettings = await _sqliteUserSettings.getUserSettings();
      if (userSettings.zodiac?.index != oldData['zodiac'] ||
          userSettings.birthYear != oldData['birth_year'] ||
          userSettings.notificationsEnabled != oldData['notifications_enabled'] ||
          userSettings.locationPermissionGranted != oldData['location_permission_granted'] ||
          userSettings.onboardingCompleted != oldData['onboarding_completed'] ||
          userSettings.termsAccepted != oldData['terms_accepted'] ||
          userSettings.privacyAccepted != oldData['privacy_accepted']) {
        _logger.error('驗證遷移結果失敗: 用戶設置不匹配');
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      _logger.error('驗證遷移結果失敗', e, stackTrace);
      return false;
    }
  }
  
  /// 回滾遷移
  Future<void> _rollback() async {
    try {
      _logger.info('開始回滾遷移');
      
      // 清除 SQLite 數據
      await _sqlitePrefs.clear();
      await _sqliteUserSettings.clear();
      
      // 恢復備份
      await _backupService.restoreFromBackup();
      
      _logger.info('回滾遷移完成');
    } catch (e, stackTrace) {
      _logger.error('回滾遷移失敗', e, stackTrace);
    }
  }
} 