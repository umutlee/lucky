import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'sqlite_preferences_service.dart';
import 'sqlite_user_settings_service.dart';

final migrationCheckServiceProvider = Provider<MigrationCheckService>((ref) {
  return MigrationCheckService(
    ref.read(sqlitePreferencesServiceProvider),
    ref.read(sqliteUserSettingsServiceProvider),
  );
});

class MigrationCheckService {
  final SQLitePreferencesService _preferencesService;
  final SQLiteUserSettingsService _userSettingsService;
  final _logger = Logger('MigrationCheckService');

  MigrationCheckService(this._preferencesService, this._userSettingsService);

  /// 檢查系統是否準備好進行遷移
  Future<MigrationCheckResult> checkMigrationReadiness() async {
    try {
      _logger.info('開始檢查遷移準備狀態');
      
      try {
        // 檢查 SQLite 服務是否正常
        final sqliteReady = await _checkSQLiteServices();
        if (!sqliteReady) {
          return MigrationCheckResult(
            isReady: false,
            reason: '無法初始化 SQLite 服務',
          );
        }
      } catch (e) {
        _logger.error('SQLite 服務檢查失敗', e);
        return MigrationCheckResult(
          isReady: false,
          reason: '無法初始化 SQLite 服務',
        );
      }

      // 檢查是否有足夠的存儲空間
      final hasSpace = await _checkStorageSpace();
      if (!hasSpace) {
        return MigrationCheckResult(
          isReady: false,
          reason: '存儲空間不足',
        );
      }

      // 檢查是否有舊數據需要遷移
      final hasOldData = await _checkOldDataExists();
      if (!hasOldData) {
        return MigrationCheckResult(
          isReady: false,
          reason: '沒有需要遷移的數據',
        );
      }

      // 檢查數據完整性
      final dataIntegrity = await _checkDataIntegrity();
      if (!dataIntegrity.isValid) {
        return MigrationCheckResult(
          isReady: false,
          reason: '數據完整性檢查失敗: ${dataIntegrity.error}',
        );
      }

      return MigrationCheckResult(
        isReady: true,
        reason: '系統已準備好進行遷移',
      );
    } catch (e, stack) {
      _logger.error('遷移準備檢查失敗', e, stack);
      return MigrationCheckResult(
        isReady: false,
        reason: '遷移準備檢查時發生錯誤: $e',
      );
    }
  }

  Future<bool> _checkSQLiteServices() async {
    await _preferencesService.init();
    await _userSettingsService.init();
    return true;
  }

  Future<bool> _checkStorageSpace() async {
    try {
      // TODO: 實現存儲空間檢查
      // 這裡需要平台特定的實現
      return true;
    } catch (e) {
      _logger.error('存儲空間檢查失敗', e);
      return false;
    }
  }

  Future<bool> _checkOldDataExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys().isNotEmpty;
    } catch (e) {
      _logger.error('舊數據檢查失敗', e);
      return false;
    }
  }

  Future<DataIntegrityResult> _checkDataIntegrity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 檢查必要的數據是否存在
      final hasNotificationSettings = prefs.containsKey('notification_enabled');
      final hasUserSettings = prefs.containsKey('user_zodiac');
      
      if (!hasNotificationSettings && !hasUserSettings) {
        return DataIntegrityResult(
          isValid: true,
          error: null,
        );
      }

      // 檢查數據格式是否正確
      if (hasNotificationSettings) {
        final enabled = prefs.getBool('notification_enabled');
        if (enabled == null) {
          return DataIntegrityResult(
            isValid: false,
            error: '通知設置數據格式錯誤',
          );
        }
      }

      if (hasUserSettings) {
        final zodiac = prefs.getString('user_zodiac');
        if (zodiac == null) {
          return DataIntegrityResult(
            isValid: false,
            error: '用戶生肖數據格式錯誤',
          );
        }
      }

      return DataIntegrityResult(
        isValid: true,
        error: null,
      );
    } catch (e) {
      return DataIntegrityResult(
        isValid: false,
        error: '數據完整性檢查失敗: $e',
      );
    }
  }
}

class MigrationCheckResult {
  final bool isReady;
  final String reason;

  MigrationCheckResult({
    required this.isReady,
    required this.reason,
  });
}

class DataIntegrityResult {
  final bool isValid;
  final String? error;

  DataIntegrityResult({
    required this.isValid,
    this.error,
  });
} 