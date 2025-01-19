import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/cache_service.dart';
import 'package:all_lucky/core/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseService databaseService;
  late CacheService cacheService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseService = DatabaseService();
    await databaseService.init();
    cacheService = CacheService(databaseService);
  });

  tearDown(() async {
    await databaseService.dispose();
  });

  group('CacheService - 基本操作', () {
    test('設置和獲取緩存', () async {
      const key = 'test_key';
      const value = {'name': 'test', 'value': 123};

      await cacheService.set(key, value);
      final result = await cacheService.get<Map<String, dynamic>>(key);

      expect(result, isNotNull);
      expect(result!['name'], 'test');
      expect(result['value'], 123);
    });

    test('緩存過期', () async {
      const key = 'expiring_key';
      const value = 'expiring_value';

      // 設置一個1秒後過期的緩存
      await cacheService.set(
        key,
        value,
        expiration: const Duration(seconds: 1),
      );

      // 立即獲取應該能獲取到
      var result = await cacheService.get<String>(key);
      expect(result, value);

      // 等待2秒後應該獲取不到
      await Future.delayed(const Duration(seconds: 2));
      result = await cacheService.get<String>(key);
      expect(result, isNull);
    });

    test('刪除緩存', () async {
      const key = 'delete_test';
      const value = 'test_value';

      await cacheService.set(key, value);
      await cacheService.remove(key);

      final result = await cacheService.get<String>(key);
      expect(result, isNull);
    });

    test('清空緩存', () async {
      // 設置多個緩存項
      await cacheService.set('key1', 'value1');
      await cacheService.set('key2', 'value2');

      await cacheService.clear();

      final result1 = await cacheService.get<String>('key1');
      final result2 = await cacheService.get<String>('key2');

      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('檢查緩存是否存在', () async {
      const key = 'exists_test';
      const value = 'test_value';

      // 初始應該不存在
      var exists = await cacheService.has(key);
      expect(exists, false);

      // 設置後應該存在
      await cacheService.set(key, value);
      exists = await cacheService.has(key);
      expect(exists, true);

      // 刪除後應該不存在
      await cacheService.remove(key);
      exists = await cacheService.has(key);
      expect(exists, false);
    });
  });

  group('CacheService - 批量操作', () {
    test('批量設置和獲取', () async {
      final entries = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': 'value3',
      };

      await cacheService.setMultiple(entries);
      final results = await cacheService.getMultiple(entries.keys.toList());

      expect(results.length, entries.length);
      expect(results['key1'], 'value1');
      expect(results['key2'], 'value2');
      expect(results['key3'], 'value3');
    });

    test('批量設置帶過期時間', () async {
      final entries = {
        'exp_key1': 'value1',
        'exp_key2': 'value2',
      };

      await cacheService.setMultiple(
        entries,
        expiration: const Duration(seconds: 1),
      );

      // 立即獲取
      var results = await cacheService.getMultiple(entries.keys.toList());
      expect(results.length, entries.length);

      // 等待過期
      await Future.delayed(const Duration(seconds: 2));
      results = await cacheService.getMultiple(entries.keys.toList());
      expect(results.isEmpty, true);
    });
  });

  group('CacheService - 性能統計', () {
    test('緩存命中統計', () async {
      const key = 'stats_test';
      const value = 'test_value';

      // 設置緩存
      await cacheService.set(key, value);

      // 獲取緩存（命中）
      await cacheService.get<String>(key);

      // 獲取不存在的緩存（未命中）
      await cacheService.get<String>('non_existent');

      final stats = cacheService.getStats();
      expect(stats['hits'], 1);
      expect(stats['misses'], 1);
      expect(stats['hitRate'], 0.5);
    });

    test('重置統計信息', () async {
      // 進行一些操作
      await cacheService.get<String>('non_existent');
      await cacheService.get<String>('non_existent');

      // 重置統計
      cacheService.resetStats();

      final stats = cacheService.getStats();
      expect(stats['hits'], 0);
      expect(stats['misses'], 0);
      expect(stats['hitRate'], 0.0);
    });
  });

  group('CacheService - 錯誤處理', () {
    test('設置無效值時應拋出異常', () async {
      final invalidValue = Object(); // 不可序列化的對象

      expect(
        () => cacheService.set('invalid_key', invalidValue),
        throwsException,
      );
    });

    test('獲取錯誤類型時應返回null', () async {
      const key = 'type_test';
      const value = 123;

      await cacheService.set(key, value);

      // 嘗試以錯誤的類型獲取
      final result = await cacheService.get<String>(key);
      expect(result, isNull);
    });
  });
} 