import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    // 初始化 FFI
    sqfliteFfiInit();
    // 設置測試數據庫工廠
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 每個測試前創建新的數據庫服務實例
    databaseService = DatabaseService();
    await databaseService.init();
  });

  tearDown(() async {
    // 每個測試後清理數據庫
    await databaseService.dispose();
  });

  group('DatabaseService - 基本操作', () {
    test('初始化數據庫', () async {
      // 驗證數據庫是否已初始化
      expect(databaseService, isNotNull);
    });

    test('插入和查詢數據', () async {
      // 準備測試數據
      final testData = {
        'id': 'test_id',
        'user_id': 'user_1',
        'type': 'daily',
        'content': '今天運勢不錯',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      // 插入數據
      final result = await databaseService.insert('fortune_records', testData);
      expect(result, 1);

      // 查詢數據
      final records = await databaseService.query(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['test_id'],
      );

      expect(records.length, 1);
      expect(records.first['content'], '今天運勢不錯');
    });

    test('更新數據', () async {
      // 插入初始數據
      final initialData = {
        'id': 'test_id',
        'user_id': 'user_1',
        'type': 'daily',
        'content': '初始內容',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };
      await databaseService.insert('fortune_records', initialData);

      // 更新數據
      final updateResult = await databaseService.update(
        'fortune_records',
        {'content': '更新後的內容'},
        where: 'id = ?',
        whereArgs: ['test_id'],
      );
      expect(updateResult, 1);

      // 驗證更新結果
      final records = await databaseService.query(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['test_id'],
      );
      expect(records.first['content'], '更新後的內容');
    });

    test('刪除數據', () async {
      // 插入測試數據
      final testData = {
        'id': 'test_id',
        'user_id': 'user_1',
        'type': 'daily',
        'content': '測試內容',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };
      await databaseService.insert('fortune_records', testData);

      // 刪除數據
      final deleteResult = await databaseService.delete(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['test_id'],
      );
      expect(deleteResult, 1);

      // 驗證刪除結果
      final records = await databaseService.query(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['test_id'],
      );
      expect(records.isEmpty, true);
    });

    test('清空表', () async {
      // 插入多條測試數據
      final testData1 = {
        'id': 'test_id_1',
        'user_id': 'user_1',
        'type': 'daily',
        'content': '測試內容1',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };
      final testData2 = {
        'id': 'test_id_2',
        'user_id': 'user_1',
        'type': 'daily',
        'content': '測試內容2',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };
      await databaseService.insert('fortune_records', testData1);
      await databaseService.insert('fortune_records', testData2);

      // 清空表
      await databaseService.clearTable('fortune_records');

      // 驗證表是否為空
      final records = await databaseService.query('fortune_records');
      expect(records.isEmpty, true);
    });
  });

  group('DatabaseService - 錯誤處理', () {
    test('插入無效數據時應拋出異常', () async {
      // 準備無效數據（缺少必要欄位）
      final invalidData = {
        'id': 'test_id',
        // 缺少 user_id, type 等必要欄位
      };

      // 驗證是否拋出異常
      expect(
        () => databaseService.insert('fortune_records', invalidData),
        throwsException,
      );
    });

    test('查詢不存在的表時應拋出異常', () async {
      expect(
        () => databaseService.query('non_existent_table'),
        throwsException,
      );
    });
  });

  group('DatabaseService - 事務處理', () {
    test('事務回滾', () async {
      try {
        await databaseService.transaction((txn) async {
          // 第一個操作成功
          await txn.insert('fortune_records', {
            'id': 'txn_test_1',
            'user_id': 'user_1',
            'type': 'daily',
            'content': '事務測試1',
            'created_at': DateTime.now().toIso8601String(),
            'is_synced': 0,
          });

          // 第二個操作失敗（插入無效數據）
          await txn.insert('fortune_records', {
            'id': 'txn_test_2',
            // 缺少必要欄位，將導致失敗
          });
        });
        fail('應該拋出異常');
      } catch (e) {
        // 驗證事務是否已回滾（第一個插入的數據也應該被回滾）
        final records = await databaseService.query(
          'fortune_records',
          where: 'id = ?',
          whereArgs: ['txn_test_1'],
        );
        expect(records.isEmpty, true);
      }
    });
  });
} 