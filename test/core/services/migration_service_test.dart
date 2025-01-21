import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/migration_service.dart';
import 'package:all_lucky/core/services/sqlite_preferences_service.dart';
import 'package:all_lucky/core/services/sqlite_user_settings_service.dart';
import 'package:all_lucky/core/models/user_settings.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/services/backup_service.dart';

import 'migration_service_test.mocks.dart';

@GenerateMocks([
  BackupService,
  SQLitePreferencesService,
  SQLiteUserSettingsService,
])
void main() {
  late MigrationService migrationService;
  late MockBackupService mockBackupService;
  late MockSQLitePreferencesService mockSqlitePrefs;
  late MockSQLiteUserSettingsService mockSqliteUserSettings;
  late Map<String, Object> testData;

  setUp(() async {
    // 初始化 mock 服務
    mockBackupService = MockBackupService();
    mockSqlitePrefs = MockSQLitePreferencesService();
    mockSqliteUserSettings = MockSQLiteUserSettingsService();
    
    // 準備測試數據
    testData = {
      'test_key': 'test_value',
      'test_bool': true,
      'test_int': 42,
      'migration_complete': false,
      'zodiac': 0,
      'birth_year': 1990,
      'notifications_enabled': true,
      'location_permission_granted': true,
      'onboarding_completed': true,
      'terms_accepted': true,
      'privacy_accepted': true,
    };
    
    // 設置 SharedPreferences mock
    SharedPreferences.setMockInitialValues(testData);
    
    // 設置基本的 mock 行為
    when(mockBackupService.createBackup()).thenAnswer((_) async => true);
    when(mockBackupService.hasBackup()).thenAnswer((_) async => true);
    when(mockBackupService.restoreFromBackup()).thenAnswer((_) async => true);
    when(mockBackupService.deleteBackup()).thenAnswer((_) async => true);
    
    when(mockSqlitePrefs.init()).thenAnswer((_) async => true);
    when(mockSqlitePrefs.getValue<String>('test_key')).thenAnswer((_) async => 'test_value');
    when(mockSqlitePrefs.getValue<bool>('migration_complete')).thenAnswer((_) async => false);
    when(mockSqlitePrefs.setValue('migration_complete', true)).thenAnswer((_) async => true);
    when(mockSqlitePrefs.clear()).thenAnswer((_) async => true);
    when(mockSqlitePrefs.migrateFromSharedPreferences(any)).thenAnswer((_) async => true);
    
    when(mockSqliteUserSettings.init()).thenAnswer((_) async => true);
    when(mockSqliteUserSettings.clear()).thenAnswer((_) async => true);
    when(mockSqliteUserSettings.getUserSettings()).thenAnswer((_) async => UserSettings(
      zodiac: Zodiac.values[0],
      birthYear: 1990,
      notificationsEnabled: true,
      locationPermissionGranted: true,
      onboardingCompleted: true,
      termsAccepted: true,
      privacyAccepted: true,
    ));
    when(mockSqliteUserSettings.migrateFromSharedPreferences(any)).thenAnswer((_) async => true);
    
    // 初始化 MigrationService
    migrationService = MigrationService(
      backupService: mockBackupService,
      sqlitePrefs: mockSqlitePrefs,
      sqliteUserSettings: mockSqliteUserSettings,
    );
  });

  group('MigrationService 測試', () {
    test('當遷移未完成時應返回需要遷移', () async {
      final needsMigration = await migrationService.needsMigration();
      expect(needsMigration, true);
    });

    test('當遷移已完成時應返回不需要遷移', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete')).thenAnswer((_) async => true);
      final needsMigration = await migrationService.needsMigration();
      expect(needsMigration, false);
    });

    test('遷移過程應該按順序執行所有步驟', () async {
      final success = await migrationService.migrateToSQLite();
      expect(success, true);
      
      verifyInOrder([
        mockBackupService.createBackup(),
        mockSqlitePrefs.init(),
        mockSqliteUserSettings.init(),
        mockSqlitePrefs.migrateFromSharedPreferences(any),
        mockSqliteUserSettings.migrateFromSharedPreferences(any),
        mockSqlitePrefs.getValue<String>('test_key'),
        mockSqliteUserSettings.getUserSettings(),
        mockSqlitePrefs.setValue('migration_complete', true),
      ]);
    });

    test('當備份創建失敗時應中止遷移', () async {
      when(mockBackupService.createBackup()).thenAnswer((_) async => false);
      final success = await migrationService.migrateToSQLite();
      expect(success, false);
      
      verifyNever(mockSqlitePrefs.migrateFromSharedPreferences(any));
      verifyNever(mockSqliteUserSettings.migrateFromSharedPreferences(any));
    });

    test('當 SQLite 服務初始化失敗時應回滾遷移', () async {
      when(mockSqlitePrefs.init()).thenAnswer((_) async => false);
      final success = await migrationService.migrateToSQLite();
      expect(success, false);
      
      verify(mockSqlitePrefs.clear()).called(1);
      verify(mockSqliteUserSettings.clear()).called(1);
      verify(mockBackupService.restoreFromBackup()).called(1);
    });

    test('當數據驗證失敗時應回滾遷移', () async {
      when(mockSqlitePrefs.getValue<String>('test_key')).thenAnswer((_) async => 'wrong_value');
      final success = await migrationService.migrateToSQLite();
      expect(success, false);
      
      verify(mockSqlitePrefs.clear()).called(1);
      verify(mockSqliteUserSettings.clear()).called(1);
      verify(mockBackupService.restoreFromBackup()).called(1);
    });
  });
} 