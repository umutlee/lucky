import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/backup_service.dart';
import 'package:all_lucky/core/services/sqlite_preferences_service.dart';
import 'package:all_lucky/core/services/sqlite_user_settings_service.dart';
import 'package:all_lucky/core/services/migration_executor.dart';
import 'package:all_lucky/core/models/user_settings.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'migration_executor_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<SQLitePreferencesService>(
    as: #MockSQLitePreferencesService,
    onMissingStub: OnMissingStub.returnDefault,
  ),
  MockSpec<SQLiteUserSettingsService>(
    as: #MockSQLiteUserSettingsService,
    onMissingStub: OnMissingStub.returnDefault,
  ),
  MockSpec<BackupService>(
    as: #MockBackupService,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockBackupService mockBackupService;
  late MockSQLitePreferencesService mockSqlitePrefs;
  late MockSQLiteUserSettingsService mockSqliteUserSettings;
  late MigrationExecutor migrationExecutor;
  late Map<String, Object> testData;

  setUp(() {
    mockBackupService = MockBackupService();
    mockSqlitePrefs = MockSQLitePreferencesService();
    mockSqliteUserSettings = MockSQLiteUserSettingsService();
    testData = {
      'test_key': 'test_value',
      'test_bool': true,
      'test_int': 42,
      'zodiac': 1,
      'birth_year': 1990,
      'notifications_enabled': true,
      'location_permission_granted': true,
      'onboarding_completed': true,
      'terms_accepted': true,
      'privacy_accepted': true,
    };

    // 設置默認的mock行為
    when(mockSqlitePrefs.init()).thenAnswer((_) => Future.value(true));
    when(mockSqlitePrefs.getValue<bool>('migration_complete'))
        .thenAnswer((_) => Future.value(true));
    when(mockSqlitePrefs.getValue<String>('test_key'))
        .thenAnswer((_) => Future.value('test_value'));
    when(mockSqlitePrefs.setValue('migration_complete', true))
        .thenAnswer((_) => Future.value(true));
    when(mockSqlitePrefs.migrateFromSharedPreferences(any))
        .thenAnswer((_) => Future.value(true));
    when(mockSqlitePrefs.clear()).thenAnswer((_) => Future.value(true));

    when(mockSqliteUserSettings.init()).thenAnswer((_) => Future.value(true));
    when(mockSqliteUserSettings.migrateFromSharedPreferences(any))
        .thenAnswer((_) => Future.value(true));
    when(mockSqliteUserSettings.clear()).thenAnswer((_) => Future.value(true));
    when(mockSqliteUserSettings.getUserSettings()).thenAnswer((_) => Future.value(UserSettings(
      zodiac: Zodiac.values[0],
      birthYear: 1990,
      notificationsEnabled: true,
      locationPermissionGranted: true,
      onboardingCompleted: true,
      termsAccepted: true,
      privacyAccepted: true,
    )));

    when(mockBackupService.createBackup()).thenAnswer((_) => Future.value(true));
    when(mockBackupService.deleteBackup()).thenAnswer((_) => Future.value(true));
    when(mockBackupService.hasBackup()).thenAnswer((_) => Future.value(false));

    migrationExecutor = MigrationExecutor(
      backupService: mockBackupService,
      sqlitePrefs: mockSqlitePrefs,
      sqliteUserSettings: mockSqliteUserSettings,
    );

    // 設置 SharedPreferences mock
    SharedPreferences.setMockInitialValues(testData);
  });

  group('MigrationExecutor 測試', () {
    test('當不需要遷移時應直接返回完成狀態', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete'))
          .thenAnswer((_) => Future.value(false));

      final result = await migrationExecutor.execute();
      expect(result.status, MigrationStatus.completed);
      expect(result.progress, 100.0);
      expect(result.currentStep, '無需遷移');
      expect(result.error, isNull);

      verifyZeroInteractions(mockBackupService);
      verifyNever(mockSqlitePrefs.init());
      verifyNever(mockSqliteUserSettings.init());
    });

    test('當需要遷移時應執行完整的遷移流程', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete'))
          .thenAnswer((_) => Future.value(true));

      final result = await migrationExecutor.execute();
      expect(result.status, MigrationStatus.completed);
      expect(result.progress, 100.0);
      expect(result.currentStep, '遷移完成');
      expect(result.error, isNull);

      verify(mockBackupService.createBackup()).called(1);
      verify(mockSqlitePrefs.init()).called(1);
      verify(mockSqliteUserSettings.init()).called(1);
      verify(mockSqlitePrefs.migrateFromSharedPreferences(any)).called(1);
      verify(mockSqliteUserSettings.migrateFromSharedPreferences(any)).called(1);
      verify(mockSqlitePrefs.setValue('migration_complete', true)).called(1);
    });

    test('當備份創建失敗時應中止遷移', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete'))
          .thenAnswer((_) => Future.value(true));
      when(mockBackupService.createBackup()).thenAnswer((_) => Future.value(false));

      final result = await migrationExecutor.execute();
      expect(result.status, MigrationStatus.failed);
      expect(result.progress, 20.0);
      expect(result.currentStep, '創建數據備份');
      expect(result.error, '創建備份失敗');

      verifyNever(mockSqlitePrefs.init());
      verifyNever(mockSqliteUserSettings.init());
    });

    test('當 SQLite 服務初始化失敗時應回滾', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete'))
          .thenAnswer((_) => Future.value(true));
      when(mockSqlitePrefs.init()).thenAnswer((_) => Future.value(false));

      final result = await migrationExecutor.execute();
      expect(result.status, MigrationStatus.failed);
      expect(result.progress, 30.0);
      expect(result.currentStep, '初始化 SQLite 服務');
      expect(result.error, '初始化 SQLite 服務失敗');

      verify(mockBackupService.createBackup()).called(1);
      verify(mockSqlitePrefs.init()).called(1);
      verifyNever(mockSqliteUserSettings.init());
      verify(mockSqlitePrefs.clear()).called(1);
      verify(mockSqliteUserSettings.clear()).called(1);
    });

    test('當數據遷移失敗時應回滾', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete'))
          .thenAnswer((_) => Future.value(true));
      when(mockSqlitePrefs.migrateFromSharedPreferences(any))
          .thenAnswer((_) => Future.value(false));

      final result = await migrationExecutor.execute();
      expect(result.status, MigrationStatus.failed);
      expect(result.progress, 50.0);
      expect(result.currentStep, '遷移數據');
      expect(result.error, '數據遷移失敗');

      verify(mockBackupService.createBackup()).called(1);
      verify(mockSqlitePrefs.init()).called(1);
      verify(mockSqliteUserSettings.init()).called(1);
      verify(mockSqlitePrefs.migrateFromSharedPreferences(any)).called(1);
      verify(mockSqlitePrefs.clear()).called(1);
      verify(mockSqliteUserSettings.clear()).called(1);
    });

    test('當數據驗證失敗時應回滾', () async {
      when(mockSqlitePrefs.getValue<bool>('migration_complete'))
          .thenAnswer((_) => Future.value(true));
      when(mockSqliteUserSettings.getUserSettings()).thenAnswer((_) => Future.value(null));

      final result = await migrationExecutor.execute();
      expect(result.status, MigrationStatus.failed);
      expect(result.progress, 80.0);
      expect(result.currentStep, '驗證遷移結果');
      expect(result.error, '數據驗證失敗');

      verify(mockBackupService.createBackup()).called(1);
      verify(mockSqlitePrefs.init()).called(1);
      verify(mockSqliteUserSettings.init()).called(1);
      verify(mockSqlitePrefs.migrateFromSharedPreferences(any)).called(1);
      verify(mockSqliteUserSettings.migrateFromSharedPreferences(any)).called(1);
      verify(mockSqlitePrefs.clear()).called(1);
      verify(mockSqliteUserSettings.clear()).called(1);
    });
  });
} 