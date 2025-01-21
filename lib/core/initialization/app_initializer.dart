import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/migration_service.dart';
import '../services/sqlite_preferences_service.dart';
import '../services/sqlite_user_settings_service.dart';
import '../utils/logger.dart';

final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer(
    ref.read(migrationServiceProvider),
    ref.read(sqlitePreferencesServiceProvider),
    ref.read(sqliteUserSettingsServiceProvider),
  );
});

class AppInitializer {
  final MigrationService _migrationService;
  final SQLitePreferencesService _preferencesService;
  final SQLiteUserSettingsService _userSettingsService;
  final _logger = Logger('AppInitializer');

  AppInitializer(
    this._migrationService,
    this._preferencesService,
    this._userSettingsService,
  );

  Future<void> initialize() async {
    try {
      _logger.info('開始初始化應用');
      
      // 初始化 SQLite 服務
      await Future.wait([
        _preferencesService.init(),
        _userSettingsService.init(),
      ]);
      
      // 檢查是否需要遷移
      if (await _migrationService.needsMigration()) {
        _logger.info('檢測到需要遷移數據');
        
        // 執行遷移
        await _migrationService.migrateToSQLite();
        
        // 驗證遷移結果
        await _validateMigration();
        
        // 清理舊數據
        await _migrationService.cleanupOldData();
        
        _logger.info('數據遷移完成');
      } else {
        _logger.info('無需遷移數據');
      }
      
      _logger.info('應用初始化完成');
    } catch (e, stack) {
      _logger.error('應用初始化失敗', e, stack);
      
      // 如果遷移過程中出錯，執行回滾
      await _migrationService.rollbackMigration();
      
      rethrow;
    }
  }

  Future<void> _validateMigration() async {
    try {
      _logger.info('開始驗證遷移結果');
      
      // 驗證偏好設置
      final hasNotification = await _preferencesService.getDailyNotification();
      final notificationTime = await _preferencesService.getNotificationTime();
      
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