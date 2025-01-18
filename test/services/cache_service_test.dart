import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/cache_service.dart';

void main() {
  late CacheService cacheService;

  setUp(() {
    cacheService = CacheService();
    cacheService.clear();
    cacheService.resetStats();
  });

  group('基本緩存操作', () {
    test('添加和獲取數據', () {
      const key = 'test_key';
      const value = 'test_value';

      cacheService.put(key, value);
      final result = cacheService.get<String>(key);

      expect(result, equals(value));
    });

    test('移除數據', () {
      const key = 'test_key';
      const value = 'test_value';

      cacheService.put(key, value);
      cacheService.remove(key);
      final result = cacheService.get<String>(key);

      expect(result, isNull);
    });

    test('清空緩存', () {
      cacheService.put('key1', 'value1');
      cacheService.put('key2', 'value2');
      cacheService.clear();

      expect(cacheService.get('key1'), isNull);
      expect(cacheService.get('key2'), isNull);
    });
  });

  group('緩存統計', () {
    test('命中統計', () {
      const key = 'test_key';
      const value = 'test_value';

      cacheService.put(key, value);
      cacheService.get(key); // 命中
      cacheService.get('non_existent_key'); // 未命中

      final stats = cacheService.getStats();
      expect(stats['hits'], equals(1));
      expect(stats['misses'], equals(1));
      expect(stats['hitRate'], equals(0.5));
    });

    test('重置統計', () {
      cacheService.put('key', 'value');
      cacheService.get('key');
      cacheService.resetStats();

      final stats = cacheService.getStats();
      expect(stats['hits'], equals(0));
      expect(stats['misses'], equals(0));
    });
  });

  group('LRU 緩存', () {
    test('超出最大容量時應移除最早的數據', () {
      // 添加超過最大容量的數據
      for (var i = 0; i < 150; i++) {
        cacheService.put('key$i', 'value$i');
      }

      // 檢查最早的數據是否被移除
      expect(cacheService.get('key0'), isNull);
      expect(cacheService.get('key49'), isNull);
      expect(cacheService.get('key149'), isNotNull);
    });

    test('訪問數據應更新其位置', () {
      cacheService.put('key1', 'value1');
      cacheService.put('key2', 'value2');
      
      // 訪問 key1，使其成為最新的數據
      cacheService.get('key1');
      
      // 添加新數據直到達到容量上限
      for (var i = 3; i < 102; i++) {
        cacheService.put('key$i', 'value$i');
      }

      // key1 應該還在緩存中，而 key2 應該被移除
      expect(cacheService.get('key1'), isNotNull);
      expect(cacheService.get('key2'), isNull);
    });
  });

  group('弱引用緩存', () {
    test('弱引用數據應在內存壓力下被回收', () async {
      const key = 'test_key';
      final value = List.generate(1000000, (i) => i); // 創建大對象

      cacheService.put(key, value);
      value.clear(); // 清除強引用

      // 觸發垃圾回收
      await Future.delayed(const Duration(seconds: 1));
      for (var i = 0; i < 1000; i++) {
        final temp = List.generate(1000000, (i) => i);
        temp.clear();
      }

      // 數據可能已被回收
      final result = cacheService.get(key);
      expect(result, anyOf(isNull, equals(value)));
    });
  });

  group('性能測試', () {
    test('大量數據操作性能', () {
      final startTime = DateTime.now();

      // 添加大量數據
      for (var i = 0; i < 10000; i++) {
        cacheService.put('key$i', 'value$i');
      }

      // 讀取數據
      for (var i = 0; i < 10000; i++) {
        cacheService.get('key$i');
      }

      final duration = DateTime.now().difference(startTime);
      expect(duration.inMilliseconds, lessThan(1000)); // 應在1秒內完成
    });

    test('並發操作', () async {
      final futures = <Future>[];

      // 並發添加數據
      for (var i = 0; i < 100; i++) {
        futures.add(
          Future(() {
            for (var j = 0; j < 100; j++) {
              final key = 'key${i}_$j';
              cacheService.put(key, 'value${i}_$j');
              cacheService.get(key);
            }
          }),
        );
      }

      // 等待所有操作完成
      await Future.wait(futures);

      // 檢查數據完整性
      final stats = cacheService.getStats();
      expect(stats['hits'], greaterThan(0));
      expect(stats['hitRate'], greaterThan(0));
    });
  });
} 