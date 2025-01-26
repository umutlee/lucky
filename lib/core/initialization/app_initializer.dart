import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/migration_service.dart';
import '../services/sqlite_preferences_service.dart';
import '../services/sqlite_user_settings_service.dart';
import '../utils/logger.dart';

/// 應用程序初始化器提供者
final appInitializerProvider = Provider<AppInitializer>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  final migrationService = ref.watch(migrationServiceProvider);
  final userSettingsService = ref.watch(sqliteUserSettingsServiceProvider);
  return AppInitializer(prefsService, migrationService, userSettingsService);
});

/// 應用程序初始化器
class AppInitializer {
  final SQLitePreferencesService _prefsService;
  final MigrationService _migrationService;
  final SQLiteUserSettingsService _userSettingsService;
  final _logger = Logger('AppInitializer');

  AppInitializer(this._prefsService, this._migrationService, this._userSettingsService);

  /// 初始化應用程序
  Future<void> initialize() async {
    try {
      _logger.info('開始初始化應用程序');

      // 初始化 SQLite 服務
      await _prefsService.init();
      await _userSettingsService.init();

      // 檢查是否需要遷移數據
      if (await _migrationService.needsMigration()) {
        _logger.info('需要遷移數據');
        await _migrationService.migrateToSQLite();
        await _validateMigration();
      }

      _logger.info('應用程序初始化完成');
    } catch (e, stackTrace) {
      _logger.error('應用程序初始化失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _validateMigration() async {
    try {
      _logger.info('開始驗證遷移結果');
      
      // 驗證偏好設置
      final hasNotification = await _prefsService.getDailyNotification();
      final notificationTime = await _prefsService.getNotificationTime();
      
      if (hasNotification == null || notificationTime == null) {
        throw Exception('偏好設置遷移驗證失敗');
      }
      
      // 驗證用戶設置
      final userSettings = await _userSettingsService.getUserSettings();
      
      if (userSettings == null) {
        throw Exception('用戶設置遷移驗證失敗');
      }
      
      _logger.info('遷移結果驗證成功');
    } catch (e, stack) {
      _logger.error('遷移結果驗證失敗', e, stack);
      rethrow;
    }
  }
} 