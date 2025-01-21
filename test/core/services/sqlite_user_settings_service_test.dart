import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/sqlite_user_settings_service.dart';
import '../../../lib/core/models/user_settings.dart';
import '../../../lib/core/models/zodiac.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late Database db;
  late DatabaseHelper dbHelper;
  late SQLiteUserSettingsService service;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 創建內存數據庫
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE user_settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              zodiac TEXT NOT NULL,
              birth_year INTEGER NOT NULL,
              has_enabled_notifications BOOLEAN DEFAULT TRUE,
              has_location_permission BOOLEAN DEFAULT FALSE,
              has_completed_onboarding BOOLEAN DEFAULT FALSE,
              has_accepted_terms BOOLEAN DEFAULT FALSE,
              has_accepted_privacy BOOLEAN DEFAULT FALSE,
              is_first_launch BOOLEAN DEFAULT TRUE,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        },
      ),
    );

    // 創建 DatabaseHelper 實例
    dbHelper = DatabaseHelper();
    // 注入測試數據庫
    when(dbHelper.database).thenAnswer((_) async => db);

    // 創建服務實例
    service = SQLiteUserSettingsService(dbHelper);
    await service.init();
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLiteUserSettingsService', () {
    test('初始化時應該設置默認值', () async {
      final settings = await service.getUserSettings();
      
      expect(settings.zodiac, Zodiac.rat);
      expect(settings.birthYear, 2000);
      expect(settings.hasEnabledNotifications, true);
      expect(settings.hasLocationPermission, false);
      expect(settings.hasCompletedOnboarding, false);
      expect(settings.hasAcceptedTerms, false);
      expect(settings.hasAcceptedPrivacy, false);
      expect(settings.isFirstLaunch, true);
    });

    test('updateUserZodiac 應該正確更新生肖', () async {
      await service.updateUserZodiac(Zodiac.dragon);
      
      final settings = await service.getUserSettings();
      expect(settings.zodiac, Zodiac.dragon);
      
      final result = await db.query('user_settings');
      expect(result.first['zodiac'], Zodiac.dragon.toString());
    });

    test('updateBirthYear 應該正確更新出生年份和生肖', () async {
      await service.updateBirthYear(1988);
      
      final settings = await service.getUserSettings();
      expect(settings.birthYear, 1988);
      expect(settings.zodiac, Zodiac.dragon);
    });

    test('updateBirthYear 應該拒絕無效的年份', () async {
      expect(
        () => service.updateBirthYear(1800),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => service.updateBirthYear(DateTime.now().year + 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateNotificationPreference 應該正確更新通知設置', () async {
      await service.updateNotificationPreference(false);
      
      final settings = await service.getUserSettings();
      expect(settings.hasEnabledNotifications, false);
      
      final result = await db.query('user_settings');
      expect(result.first['has_enabled_notifications'], 0);
    });

    test('updateLocationPermission 應該正確更新位置權限', () async {
      await service.updateLocationPermission(true);
      
      final settings = await service.getUserSettings();
      expect(settings.hasLocationPermission, true);
      
      final result = await db.query('user_settings');
      expect(result.first['has_location_permission'], 1);
    });

    test('completeOnboarding 應該正確更新引導完成狀態', () async {
      await service.completeOnboarding();
      
      final settings = await service.getUserSettings();
      expect(settings.hasCompletedOnboarding, true);
      expect(settings.isFirstLaunch, false);
      
      final result = await db.query('user_settings');
      expect(result.first['has_completed_onboarding'], 1);
      expect(result.first['is_first_launch'], 0);
    });

    test('acceptTerms 應該正確更新條款接受狀態', () async {
      await service.acceptTerms();
      
      final settings = await service.getUserSettings();
      expect(settings.hasAcceptedTerms, true);
      
      final result = await db.query('user_settings');
      expect(result.first['has_accepted_terms'], 1);
    });

    test('acceptPrivacy 應該正確更新隱私政策接受狀態', () async {
      await service.acceptPrivacy();
      
      final settings = await service.getUserSettings();
      expect(settings.hasAcceptedPrivacy, true);
      
      final result = await db.query('user_settings');
      expect(result.first['has_accepted_privacy'], 1);
    });

    test('migrateFromSharedPreferences 應該正確遷移數據', () async {
      final oldSettings = UserSettings(
        zodiac: Zodiac.snake,
        birthYear: 1989,
        hasEnabledNotifications: false,
        hasLocationPermission: true,
        hasCompletedOnboarding: true,
        hasAcceptedTerms: true,
        hasAcceptedPrivacy: true,
        isFirstLaunch: false,
      );
      
      final jsonStr = jsonEncode(oldSettings.toJson());
      await service.migrateFromSharedPreferences(jsonStr);
      
      final settings = await service.getUserSettings();
      expect(settings.zodiac, Zodiac.snake);
      expect(settings.birthYear, 1989);
      expect(settings.hasEnabledNotifications, false);
      expect(settings.hasLocationPermission, true);
      expect(settings.hasCompletedOnboarding, true);
      expect(settings.hasAcceptedTerms, true);
      expect(settings.hasAcceptedPrivacy, true);
      expect(settings.isFirstLaunch, false);
    });

    test('在數據庫錯誤時應該返回默認值', () async {
      await db.close();
      
      final settings = await service.getUserSettings();
      expect(settings.zodiac, Zodiac.rat);
      expect(settings.birthYear, 2000);
      expect(settings.hasEnabledNotifications, true);
      expect(settings.hasLocationPermission, false);
      expect(settings.hasCompletedOnboarding, false);
      expect(settings.hasAcceptedTerms, false);
      expect(settings.hasAcceptedPrivacy, false);
      expect(settings.isFirstLaunch, true);
    });
  });
} 