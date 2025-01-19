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
      final data = {
        'id': '1',
        'user_id': 'user1',
        'type': 'daily',
        'content': 'test content',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      await databaseService.insert('fortune_records', data);

      final results = await databaseService.query(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['1'],
      );

      expect(results.length, 1);
      expect(results.first['content'], 'test content');
    });

    test('更新數據', () async {
      final data = {
        'id': '1',
        'user_id': 'user1',
        'type': 'daily',
        'content': 'old content',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      await databaseService.insert('fortune_records', data);

      await databaseService.update(
        'fortune_records',
        {'content': 'new content'},
        where: 'id = ?',
        whereArgs: ['1'],
      );

      final results = await databaseService.query(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['1'],
      );

      expect(results.first['content'], 'new content');
    });

    test('刪除數據', () async {
      final data = {
        'id': '1',
        'user_id': 'user1',
        'type': 'daily',
        'content': 'test content',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      await databaseService.insert('fortune_records', data);

      await databaseService.delete(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['1'],
      );

      final results = await databaseService.query(
        'fortune_records',
        where: 'id = ?',
        whereArgs: ['1'],
      );

      expect(results.isEmpty, true);
    });

    test('清空表', () async {
      final data1 = {
        'id': '1',
        'user_id': 'user1',
        'type': 'daily',
        'content': 'test content 1',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      final data2 = {
        'id': '2',
        'user_id': 'user1',
        'type': 'daily',
        'content': 'test content 2',
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      await databaseService.insert('fortune_records', data1);
      await databaseService.insert('fortune_records', data2);

      await databaseService.clearTable('fortune_records');

      final results = await databaseService.query('fortune_records');
      expect(results.isEmpty, true);
    });
  });

  group('DatabaseService - 錯誤處理', () {
    test('插入無效數據', () async {
      expect(
        () => databaseService.insert('fortune_records', {
          'invalid_column': 'value',
        }),
        throwsException,
      );
    });

    test('查詢不存在的表', () async {
      expect(
        () => databaseService.query('non_existent_table'),
        throwsException,
      );
    });

    test('更新不存在的記錄', () async {
      final result = await databaseService.update(
        'fortune_records',
        {'content': 'new content'},
        where: 'id = ?',
        whereArgs: ['non_existent'],
      );
      expect(result, 0);
    });
  });

  group('DatabaseService - 事務處理', () {
    test('成功的事務操作', () async {
      await databaseService.transaction((txn) async {
        await txn.insert('fortune_records', {
          'id': '1',
          'user_id': 'user1',
          'type': 'daily',
          'content': 'transaction test 1',
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
        });

        await txn.insert('fortune_records', {
          'id': '2',
          'user_id': 'user1',
          'type': 'daily',
          'content': 'transaction test 2',
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
        });
      });

      final results = await databaseService.query('fortune_records');
      expect(results.length, 2);
    });

    test('事務回滾', () async {
      expect(
        () => databaseService.transaction((txn) async {
          await txn.insert('fortune_records', {
            'id': '1',
            'user_id': 'user1',
            'type': 'daily',
            'content': 'rollback test 1',
            'created_at': DateTime.now().toIso8601String(),
            'is_synced': 0,
          });

          // 插入無效數據觸發錯誤
          await txn.insert('fortune_records', {
            'id': '1', // 重複的主鍵
            'user_id': 'user1',
            'type': 'daily',
            'content': 'rollback test 2',
            'created_at': DateTime.now().toIso8601String(),
            'is_synced': 0,
          });
        }),
        throwsException,
      );

      final results = await databaseService.query('fortune_records');
      expect(results.isEmpty, true);
    });
  });
} 