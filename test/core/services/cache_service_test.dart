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
      await cacheService.set('test_key', 'test_value');
      final value = await cacheService.get<String>('test_key');
      expect(value, 'test_value');
    });

    test('設置帶過期時間的緩存', () async {
      await cacheService.set(
        'expiring_key',
        'expiring_value',
        expiration: Duration(milliseconds: 100),
      );

      final immediateValue = await cacheService.get<String>('expiring_key');
      expect(immediateValue, 'expiring_value');

      await Future.delayed(Duration(milliseconds: 150));

      final expiredValue = await cacheService.get<String>('expiring_key');
      expect(expiredValue, null);
    });

    test('檢查緩存是否存在', () async {
      await cacheService.set('existing_key', 'value');
      expect(await cacheService.has('existing_key'), true);
      expect(await cacheService.has('non_existing_key'), false);
    });

    test('刪除緩存', () async {
      await cacheService.set('delete_key', 'value');
      await cacheService.remove('delete_key');
      expect(await cacheService.has('delete_key'), false);
    });

    test('清空緩存', () async {
      await cacheService.set('key1', 'value1');
      await cacheService.set('key2', 'value2');
      await cacheService.clear();
      expect(await cacheService.has('key1'), false);
      expect(await cacheService.has('key2'), false);
    });
  });

  group('CacheService - 批量操作', () {
    test('批量設置和獲取緩存', () async {
      final entries = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': 'value3',
      };

      await cacheService.setMultiple(entries);

      final values = await cacheService.getMultiple<String>(entries.keys.toList());
      expect(values, entries);
    });

    test('批量設置帶過期時間的緩存', () async {
      final entries = {
        'exp_key1': 'value1',
        'exp_key2': 'value2',
      };

      await cacheService.setMultiple(
        entries,
        expiration: Duration(milliseconds: 100),
      );

      final immediateValues = await cacheService.getMultiple<String>(entries.keys.toList());
      expect(immediateValues, entries);

      await Future.delayed(Duration(milliseconds: 150));

      final expiredValues = await cacheService.getMultiple<String>(entries.keys.toList());
      expect(expiredValues.values.every((v) => v == null), true);
    });

    test('批量刪除緩存', () async {
      await cacheService.setMultiple({
        'del_key1': 'value1',
        'del_key2': 'value2',
      });

      await cacheService.removeMultiple(['del_key1', 'del_key2']);

      final values = await cacheService.getMultiple<String>(['del_key1', 'del_key2']);
      expect(values.values.every((v) => v == null), true);
    });
  });

  group('CacheService - 內存緩存', () {
    test('優先使用內存緩存', () async {
      await cacheService.set('memory_key', 'memory_value');
      
      // 第一次獲取會從數據庫讀取
      final firstValue = await cacheService.get<String>('memory_key');
      expect(firstValue, 'memory_value');

      // 第二次獲取應該從內存讀取
      final stats1 = cacheService.getStats();
      final secondValue = await cacheService.get<String>('memory_key');
      final stats2 = cacheService.getStats();

      expect(secondValue, 'memory_value');
      expect(stats2['memoryHits']! - stats1['memoryHits']!, 1);
    });

    test('禁用內存緩存', () async {
      await cacheService.set('disk_key', 'disk_value', useMemoryCache: false);
      
      final stats1 = cacheService.getStats();
      final value = await cacheService.get<String>('disk_key', useMemoryCache: false);
      final stats2 = cacheService.getStats();

      expect(value, 'disk_value');
      expect(stats2['diskHits']! - stats1['diskHits']!, 1);
      expect(stats2['memoryHits'], stats1['memoryHits']);
    });
  });

  group('CacheService - 性能統計', () {
    test('統計命中率', () async {
      // 設置一些測試數據
      await cacheService.setMultiple({
        'stat_key1': 'value1',
        'stat_key2': 'value2',
      });

      // 進行一些緩存操作
      await cacheService.get<String>('stat_key1'); // 磁盤命中
      await cacheService.get<String>('stat_key1'); // 內存命中
      await cacheService.get<String>('non_existent'); // 未命中

      final stats = cacheService.getStats();
      expect(stats['memoryHits'], 1);
      expect(stats['diskHits'], 1);
      expect(stats['misses'], 1);
      expect(stats['hitRatio'], 67); // (1 + 1) / (1 + 1 + 1) * 100 ≈ 67%
    });

    test('重置統計信息', () async {
      await cacheService.set('reset_key', 'value');
      await cacheService.get<String>('reset_key');
      await cacheService.get<String>('reset_key');

      final stats1 = cacheService.getStats();
      expect(stats1['totalHits']! > 0, true);

      await cacheService.clear(); // 清空緩存同時重置統計信息

      final stats2 = cacheService.getStats();
      expect(stats2['memoryHits'], 0);
      expect(stats2['diskHits'], 0);
      expect(stats2['misses'], 0);
      expect(stats2['writes'], 0);
    });
  });

  group('CacheService - 錯誤處理', () {
    test('獲取不存在的緩存', () async {
      final value = await cacheService.get<String>('non_existent_key');
      expect(value, null);

      final stats = cacheService.getStats();
      expect(stats['misses']! > 0, true);
    });

    test('設置無效的緩存值', () async {
      // 測試設置無效的 JSON 值
      final invalidObject = Object();
      expect(() async {
        await cacheService.set('invalid_key', invalidObject);
      }, throwsException);
    });

    test('批量操作部分失敗', () async {
      final entries = {
        'valid_key': 'valid_value',
        'invalid_key': Object(), // 無效的 JSON 值
      };

      expect(() async {
        await cacheService.setMultiple(entries);
      }, throwsException);

      // 確保沒有部分寫入
      final value = await cacheService.get<String>('valid_key');
      expect(value, null);
    });
  });
} 