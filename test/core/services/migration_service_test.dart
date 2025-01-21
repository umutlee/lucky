import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../lib/core/services/migration_service.dart';
import '../../../lib/core/services/sqlite_preferences_service.dart';
import '../../../lib/core/services/sqlite_user_settings_service.dart';
import '../../../lib/core/models/user_settings.dart';
import '../../../lib/core/models/zodiac.dart';

@GenerateMocks([
  SQLitePreferencesService,
  SQLiteUserSettingsService,
])
void main() {
  late SQLitePreferencesService mockPreferencesService;
  late SQLiteUserSettingsService mockUserSettingsService;
  late MigrationService migrationService;
  late Map<String, Object> fakeSharedPrefs;

  setUp(() async {
    mockPreferencesService = MockSQLitePreferencesService();
    mockUserSettingsService = MockSQLiteUserSettingsService();
    migrationService = MigrationService(
      mockPreferencesService,
      mockUserSettingsService,
    );

    // 設置假的 SharedPreferences 數據
    fakeSharedPrefs = {
      'daily_notification': true,
      'notification_time': '09:00',
      'user_settings': jsonEncode({
        'zodiac': 'Zodiac.dragon',
        'birthYear': 1988,
        'hasEnabledNotifications': true,
        'hasLocationPermission': true,
        'hasCompletedOnboarding': true,
        'hasAcceptedTerms': true,
        'hasAcceptedPrivacy': true,
        'isFirstLaunch': false,
      }),
      'sqlite_migration_complete': false,
    };

    SharedPreferences.setMockInitialValues(fakeSharedPrefs);
  });

  group('MigrationService', () {
    test('needsMigration 應該正確檢查遷移狀態', () async {
      expect(await migrationService.needsMigration(), true);

      // 設置遷移完成標記
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sqlite_migration_complete', true);

      expect(await migrationService.needsMigration(), false);
    });

    test('migrateToSQLite 應該正確遷移所有數據', () async {
      // 設置 mock 行為
      when(mockPreferencesService.migrateFromSharedPreferences(any))
          .thenAnswer((_) async {});
      when(mockUserSettingsService.migrateFromSharedPreferences(any))
          .thenAnswer((_) async {});

      // 執行遷移
      await migrationService.migrateToSQLite();

      // 驗證偏好設置遷移
      verify(mockPreferencesService.migrateFromSharedPreferences({
        'daily_notification': true,
        'notification_time': '09:00',
      })).called(1);

      // 驗證用戶設置遷移
      verify(mockUserSettingsService.migrateFromSharedPreferences(
        fakeSharedPrefs['user_settings'] as String,
      )).called(1);

      // 驗證遷移完成標記
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sqlite_migration_complete'), true);
    });

    test('rollbackMigration 應該正確回滾遷移狀態', () async {
      // 先標記遷移為完成
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sqlite_migration_complete', true);

      // 執行回滾
      await migrationService.rollbackMigration();

      // 驗證遷移標記已被移除
      expect(prefs.getBool('sqlite_migration_complete'), null);
    });

    test('cleanupOldData 應該正確清理舊數據', () async {
      // 執行清理
      await migrationService.cleanupOldData();

      // 驗證舊數據已被清理
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('daily_notification'), null);
      expect(prefs.getString('notification_time'), null);
      expect(prefs.getString('user_settings'), null);
    });

    test('遷移過程中出現錯誤時應該拋出異常', () async {
      // 模擬遷移錯誤
      when(mockPreferencesService.migrateFromSharedPreferences(any))
          .thenThrow(Exception('遷移失敗'));

      // 驗證錯誤處理
      expect(
        () => migrationService.migrateToSQLite(),
        throwsException,
      );

      // 驗證遷移未標記為完成
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sqlite_migration_complete'), false);
    });
  });
} 