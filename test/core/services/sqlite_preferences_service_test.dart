import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/sqlite_preferences_service.dart';

@GenerateMocks([PathProviderPlatform])
void main() {
  late Database db;
  late DatabaseHelper dbHelper;
  late SQLitePreferencesService service;

  setUpAll(() {
    // 初始化 sqflite_ffi
    sqfliteFfiInit();
    // 設置測試工廠
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
            CREATE TABLE preferences (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL,
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
    service = SQLitePreferencesService(dbHelper);
    await service.init();
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLitePreferencesService', () {
    test('初始化時應該設置默認值', () async {
      // 檢查默認值
      expect(await service.getDailyNotification(), true);
      expect(await service.getNotificationTime(), '08:00');
    });

    test('setDailyNotification 應該正確保存值', () async {
      // 設置值
      await service.setDailyNotification(false);
      
      // 驗證值
      expect(await service.getDailyNotification(), false);
      
      // 檢查數據庫記錄
      final result = await db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['daily_notification'],
      );
      expect(result.length, 1);
      expect(result.first['value'], 'false');
    });

    test('setNotificationTime 應該正確保存值', () async {
      // 設置值
      const testTime = '10:30';
      await service.setNotificationTime(testTime);
      
      // 驗證值
      expect(await service.getNotificationTime(), testTime);
      
      // 檢查數據庫記錄
      final result = await db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['notification_time'],
      );
      expect(result.length, 1);
      expect(result.first['value'], testTime);
    });

    test('clear 應該清除所有設置', () async {
      // 先設置一些值
      await service.setDailyNotification(false);
      await service.setNotificationTime('10:30');
      
      // 清除所有設置
      await service.clear();
      
      // 檢查數據庫是否為空
      final result = await db.query('preferences');
      expect(result.isEmpty, true);
    });

    test('migrateFromSharedPreferences 應該正確遷移數據', () async {
      // 模擬舊數據
      final oldData = {
        'daily_notification': false,
        'notification_time': '11:00',
      };
      
      // 執行遷移
      await service.migrateFromSharedPreferences(oldData);
      
      // 驗證遷移後的值
      expect(await service.getDailyNotification(), false);
      expect(await service.getNotificationTime(), '11:00');
      
      // 檢查數據庫記錄
      final result = await db.query('preferences');
      expect(result.length, 2);
    });

    test('在數據庫錯誤時應該返回默認值', () async {
      // 關閉數據庫連接來模擬錯誤
      await db.close();
      
      // 應該返回默認值
      expect(await service.getDailyNotification(), true);
      expect(await service.getNotificationTime(), '08:00');
    });
  });
} 