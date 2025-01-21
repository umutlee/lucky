import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../../lib/core/initialization/app_initializer.dart';
import '../../../lib/core/services/migration_service.dart';
import '../../../lib/core/services/sqlite_preferences_service.dart';
import '../../../lib/core/services/sqlite_user_settings_service.dart';
import '../../../lib/core/models/user_settings.dart';
import '../../../lib/core/models/zodiac.dart';

@GenerateMocks([
  MigrationService,
  SQLitePreferencesService,
  SQLiteUserSettingsService,
])
void main() {
  late MigrationService mockMigrationService;
  late SQLitePreferencesService mockPreferencesService;
  late SQLiteUserSettingsService mockUserSettingsService;
  late AppInitializer appInitializer;

  setUp(() {
    mockMigrationService = MockMigrationService();
    mockPreferencesService = MockSQLitePreferencesService();
    mockUserSettingsService = MockSQLiteUserSettingsService();
    appInitializer = AppInitializer(
      mockMigrationService,
      mockPreferencesService,
      mockUserSettingsService,
    );
  });

  group('AppInitializer', () {
    test('當不需要遷移時應該只初始化服務', () async {
      // 設置 mock 行為
      when(mockMigrationService.needsMigration())
          .thenAnswer((_) async => false);
      when(mockPreferencesService.init())
          .thenAnswer((_) async {});
      when(mockUserSettingsService.init())
          .thenAnswer((_) async {});

      // 執行初始化
      await appInitializer.initialize();

      // 驗證調用
      verify(mockPreferencesService.init()).called(1);
      verify(mockUserSettingsService.init()).called(1);
      verify(mockMigrationService.needsMigration()).called(1);
      verifyNever(mockMigrationService.migrateToSQLite());
      verifyNever(mockMigrationService.cleanupOldData());
    });

    test('當需要遷移時應該執行完整的遷移流程', () async {
      // 設置 mock 行為
      when(mockMigrationService.needsMigration())
          .thenAnswer((_) async => true);
      when(mockMigrationService.migrateToSQLite())
          .thenAnswer((_) async {});
      when(mockMigrationService.cleanupOldData())
          .thenAnswer((_) async {});
      when(mockPreferencesService.init())
          .thenAnswer((_) async {});
      when(mockUserSettingsService.init())
          .thenAnswer((_) async {});
      when(mockPreferencesService.getDailyNotification())
          .thenAnswer((_) async => true);
      when(mockPreferencesService.getNotificationTime())
          .thenAnswer((_) async => '08:00');
      when(mockUserSettingsService.getUserSettings())
          .thenAnswer((_) async => UserSettings.defaultSettings());

      // 執行初始化
      await appInitializer.initialize();

      // 驗證調用順序
      verifyInOrder([
        mockPreferencesService.init(),
        mockUserSettingsService.init(),
        mockMigrationService.needsMigration(),
        mockMigrationService.migrateToSQLite(),
        mockPreferencesService.getDailyNotification(),
        mockPreferencesService.getNotificationTime(),
        mockUserSettingsService.getUserSettings(),
        mockMigrationService.cleanupOldData(),
      ]);
    });

    test('當遷移失敗時應該執行回滾', () async {
      // 設置 mock 行為
      when(mockMigrationService.needsMigration())
          .thenAnswer((_) async => true);
      when(mockMigrationService.migrateToSQLite())
          .thenThrow(Exception('遷移失敗'));
      when(mockMigrationService.rollbackMigration())
          .thenAnswer((_) async {});
      when(mockPreferencesService.init())
          .thenAnswer((_) async {});
      when(mockUserSettingsService.init())
          .thenAnswer((_) async {});

      // 執行初始化並期望拋出異常
      expect(
        () => appInitializer.initialize(),
        throwsException,
      );

      // 驗證回滾被調用
      verify(mockMigrationService.rollbackMigration()).called(1);
    });

    test('當驗證失敗時應該執行回滾', () async {
      // 設置 mock 行為
      when(mockMigrationService.needsMigration())
          .thenAnswer((_) async => true);
      when(mockMigrationService.migrateToSQLite())
          .thenAnswer((_) async {});
      when(mockMigrationService.rollbackMigration())
          .thenAnswer((_) async {});
      when(mockPreferencesService.init())
          .thenAnswer((_) async {});
      when(mockUserSettingsService.init())
          .thenAnswer((_) async {});
      when(mockPreferencesService.getDailyNotification())
          .thenAnswer((_) async => null);
      when(mockPreferencesService.getNotificationTime())
          .thenAnswer((_) async => null);

      // 執行初始化並期望拋出異常
      expect(
        () => appInitializer.initialize(),
        throwsException,
      );

      // 驗證回滾被調用
      verify(mockMigrationService.rollbackMigration()).called(1);
    });
  });
} 