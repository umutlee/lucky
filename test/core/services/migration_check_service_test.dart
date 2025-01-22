import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/migration_check_service.dart';
import 'package:all_lucky/core/services/sqlite_preferences_service.dart';
import 'package:all_lucky/core/services/sqlite_user_settings_service.dart';
import 'migration_check_service_test.mocks.dart';

@GenerateMocks([
  SQLitePreferencesService,
  SQLiteUserSettingsService,
])
void main() {
  late MigrationCheckService migrationCheckService;
  late SQLitePreferencesService mockPreferencesService;
  late SQLiteUserSettingsService mockUserSettingsService;

  setUp(() {
    mockPreferencesService = MockSQLitePreferencesService();
    mockUserSettingsService = MockSQLiteUserSettingsService();
    migrationCheckService = MigrationCheckService(
      mockPreferencesService,
      mockUserSettingsService,
    );
  });

  group('MigrationCheckService', () {
    test('當 SQLite 服務初始化失敗時應返回未準備好狀態', () async {
      // 設置 mock
      when(mockPreferencesService.init())
          .thenThrow(Exception('SQLite 初始化失敗'));

      // 執行檢查
      final result = await migrationCheckService.checkMigrationReadiness();

      // 驗證結果
      expect(result.isReady, false);
      expect(result.reason, contains('無法初始化 SQLite 服務'));
    });

    test('當沒有舊數據時應返回未準備好狀態', () async {
      // 設置 mock
      when(mockPreferencesService.init()).thenAnswer((_) async => true);
      when(mockUserSettingsService.init()).thenAnswer((_) async => true);
      
      // 設置空的 SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // 執行檢查
      final result = await migrationCheckService.checkMigrationReadiness();

      // 驗證結果
      expect(result.isReady, false);
      expect(result.reason, contains('沒有需要遷移的數據'));
    });

    test('當數據完整性檢查失敗時應返回未準備好狀態', () async {
      // 設置 mock
      when(mockPreferencesService.init()).thenAnswer((_) async => true);
      when(mockUserSettingsService.init()).thenAnswer((_) async => true);
      
      // 設置無效的數據
      SharedPreferences.setMockInitialValues({
        'notification_enabled': 'invalid_value', // 應該是布爾值
      });

      // 執行檢查
      final result = await migrationCheckService.checkMigrationReadiness();

      // 驗證結果
      expect(result.isReady, false);
      expect(result.reason, contains('數據完整性檢查失敗'));
    });

    test('當所有檢查都通過時應返回準備好狀態', () async {
      // 設置 mock
      when(mockPreferencesService.init()).thenAnswer((_) async => true);
      when(mockUserSettingsService.init()).thenAnswer((_) async => true);
      
      // 設置有效的測試數據
      SharedPreferences.setMockInitialValues({
        'notification_enabled': true,
        'user_zodiac': 'rat',
      });

      // 執行檢查
      final result = await migrationCheckService.checkMigrationReadiness();

      // 驗證結果
      expect(result.isReady, true);
      expect(result.reason, contains('系統已準備好進行遷移'));
    });

    test('當發生意外錯誤時應返回未準備好狀態', () async {
      // 設置 mock 拋出意外錯誤
      when(mockPreferencesService.init()).thenAnswer((_) async => true);
      when(mockUserSettingsService.init())
          .thenThrow(Exception('意外錯誤'));

      // 執行檢查
      final result = await migrationCheckService.checkMigrationReadiness();

      // 驗證結果
      expect(result.isReady, false);
      expect(result.reason, contains('無法初始化 SQLite 服務'));
    });
  });
} 