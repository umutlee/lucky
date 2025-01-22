import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/services/migration_service.dart';
import 'package:all_lucky/core/services/backup_service.dart';
import 'package:all_lucky/core/services/sqlite_preferences_service.dart';
import 'package:all_lucky/core/services/sqlite_user_settings_service.dart';

/// 遷移狀態
enum MigrationStatus {
  notStarted,    // 未開始
  inProgress,    // 進行中
  completed,     // 已完成
  failed,        // 失敗
  rolledBack     // 已回滾
}

/// 遷移進度
class MigrationProgress {
  final MigrationStatus status;
  final double progress;      // 0-100
  final String currentStep;   // 當前步驟
  final String? error;       // 錯誤信息

  const MigrationProgress({
    required this.status,
    required this.progress,
    required this.currentStep,
    this.error,
  });

  MigrationProgress copyWith({
    MigrationStatus? status,
    double? progress,
    String? currentStep,
    String? error,
  }) {
    return MigrationProgress(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      error: error ?? this.error,
    );
  }
}

final migrationExecutorProvider = Provider((ref) {
  final migrationService = ref.watch(migrationServiceProvider);
  final backupService = ref.watch(backupServiceProvider);
  final sqlitePrefs = ref.watch(sqlitePreferencesServiceProvider);
  final sqliteUserSettings = ref.watch(sqliteUserSettingsServiceProvider);
  
  return MigrationExecutor(
    backupService: backupService,
    sqlitePrefs: sqlitePrefs,
    sqliteUserSettings: sqliteUserSettings,
  );
});

/// 數據遷移執行器
class MigrationExecutor {
  final BackupService _backupService;
  final SQLitePreferencesService _sqlitePrefs;
  final SQLiteUserSettingsService _sqliteUserSettings;
  final _logger = Logger('MigrationExecutor');
  
  MigrationProgress _progress = MigrationProgress(
    status: MigrationStatus.notStarted,
    progress: 0.0,
    currentStep: '未開始',
    error: null,
  );

  MigrationExecutor({
    required BackupService backupService,
    required SQLitePreferencesService sqlitePrefs,
    required SQLiteUserSettingsService sqliteUserSettings,
  }) : _backupService = backupService,
       _sqlitePrefs = sqlitePrefs,
       _sqliteUserSettings = sqliteUserSettings;

  /// 獲取當前遷移進度
  MigrationProgress get progress => _progress;

  /// 執行遷移
  Future<MigrationProgress> execute() async {
    try {
      // 檢查是否需要遷移
      final needsMigration = await _sqlitePrefs.getValue<bool>('migration_complete') ?? true;
      if (!needsMigration) {
        _updateProgress(MigrationStatus.completed, 100.0, '無需遷移');
        return _progress;
      }

      // 開始遷移
      _updateProgress(MigrationStatus.inProgress, 10.0, '開始遷移過程');

      // 創建備份
      _updateProgress(MigrationStatus.inProgress, 20.0, '創建數據備份');
      if (!await _backupService.createBackup()) {
        _updateProgress(MigrationStatus.failed, 20.0, '創建數據備份', error: '創建備份失敗');
        return _progress;
      }

      // 初始化 SQLite 服務
      _updateProgress(MigrationStatus.inProgress, 30.0, '初始化 SQLite 服務');
      if (!await _sqlitePrefs.init() || !await _sqliteUserSettings.init()) {
        _updateProgress(MigrationStatus.failed, 30.0, '初始化 SQLite 服務', error: '初始化 SQLite 服務失敗');
        await _rollback();
        return _progress;
      }

      // 遷移數據
      _updateProgress(MigrationStatus.inProgress, 50.0, '遷移數據');
      if (!await _migrateData()) {
        _updateProgress(MigrationStatus.failed, 50.0, '遷移數據', error: '數據遷移失敗');
        await _rollback();
        return _progress;
      }

      // 驗證遷移結果
      _updateProgress(MigrationStatus.inProgress, 80.0, '驗證遷移結果');
      if (!await _validateMigration()) {
        _updateProgress(MigrationStatus.failed, 80.0, '驗證遷移結果', error: '數據驗證失敗');
        await _rollback();
        return _progress;
      }

      // 完成遷移
      await _sqlitePrefs.setValue('migration_complete', true);
      _updateProgress(MigrationStatus.completed, 100.0, '遷移完成');
      return _progress;
    } catch (e, stackTrace) {
      _logger.error('遷移失敗', e, stackTrace);
      _updateProgress(MigrationStatus.failed, _progress.progress, _progress.currentStep, error: e.toString());
      await _rollback();
      return _progress;
    }
  }

  /// 更新進度
  void _updateProgress(MigrationStatus status, double progress, String currentStep, {String? error}) {
    _progress = MigrationProgress(
      status: status,
      progress: progress,
      currentStep: currentStep,
      error: error,
    );
    _logger.info('遷移進度更新: $currentStep ($progress%)');
  }

  Future<bool> _migrateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldData = <String, Object>{
        'test_key': prefs.getString('test_key') ?? '',
        'test_bool': prefs.getBool('test_bool') ?? false,
        'test_int': prefs.getInt('test_int') ?? 0,
        'zodiac': prefs.getInt('zodiac') ?? 0,
        'birth_year': prefs.getInt('birth_year') ?? 0,
        'notifications_enabled': prefs.getBool('notifications_enabled') ?? false,
        'location_permission_granted': prefs.getBool('location_permission_granted') ?? false,
        'onboarding_completed': prefs.getBool('onboarding_completed') ?? false,
        'terms_accepted': prefs.getBool('terms_accepted') ?? false,
        'privacy_accepted': prefs.getBool('privacy_accepted') ?? false,
      };

      final prefsSuccess = await _sqlitePrefs.migrateFromSharedPreferences(oldData);
      final userSettingsSuccess = await _sqliteUserSettings.migrateFromSharedPreferences(oldData);

      return prefsSuccess && userSettingsSuccess;
    } catch (e) {
      _logger.error('數據遷移失敗: $e');
      return false;
    }
  }

  Future<bool> _validateMigration() async {
    try {
      // 驗證偏好設置
      final newPrefs = await _sqlitePrefs.getValue<String>('test_key');
      if (newPrefs == null) {
        _logger.error('偏好設置驗證失敗');
        return false;
      }

      // 驗證用戶設置
      final newSettings = await _sqliteUserSettings.getUserSettings();
      if (newSettings == null) {
        _logger.error('用戶設置驗證失敗');
        return false;
      }

      return true;
    } catch (e) {
      _logger.error('驗證失敗: $e');
      return false;
    }
  }

  Future<void> _rollback() async {
    try {
      await _sqlitePrefs.clear();
      await _sqliteUserSettings.clear();
    } catch (e, stackTrace) {
      _logger.error('回滾失敗', e, stackTrace);
    }
  }
} 