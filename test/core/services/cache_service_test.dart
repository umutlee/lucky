import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/cache_service.dart';
import '../../../lib/core/models/fortune.dart';
import '../../../lib/core/models/fortune_type.dart';
import '../../../lib/core/utils/logger.dart';
import 'cache_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late CacheService cacheService;
  late DateTime fixedTime;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    cacheService = CacheServiceFactory.create(mockDatabaseHelper);
    fixedTime = DateTime.now();
  });

  group('CacheService', () {
    test('should set and get cache', () async {
      const key = 'test_key';
      const value = 'test_value';

      await cacheService.set(key, value);
      final result = await cacheService.get<String>(key, (json) => json as String);

      expect(result, value);
    });

    test('should get persistent cache from database', () async {
      const key = 'test_key';
      const value = 'test_value';
      final config = CacheConfig(isPersistent: true);

      when(mockDatabaseHelper.query(
        'cache',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [
        {
          'value': '{"data":"test_value","expiresAt":"${fixedTime.add(const Duration(hours: 1)).toIso8601String()}","createdAt":"${fixedTime.toIso8601String()}","lastAccessedAt":"${fixedTime.toIso8601String()}","accessCount":0}',
        },
      ]);

      when(mockDatabaseHelper.insert(
        'cache',
        any,
        conflictResolution: 'REPLACE',
      )).thenAnswer((_) async => 1);

      await cacheService.set(key, value, config: config);
      final result = await cacheService.get<String>(key, (json) => json as String, config: config);

      expect(result, value);
      verify(mockDatabaseHelper.query(
        'cache',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('should remove cache', () async {
      const key = 'test_key';
      const value = 'test_value';

      when(mockDatabaseHelper.delete(
        'cache',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      await cacheService.set(key, value);
      await cacheService.remove(key);
      final result = await cacheService.get<String>(key, (json) => json as String);

      expect(result, null);
    });

    test('should clear all cache', () async {
      const key1 = 'test_key1';
      const key2 = 'test_key2';
      const value = 'test_value';

      when(mockDatabaseHelper.delete('cache')).thenAnswer((_) async => 1);

      await cacheService.set(key1, value);
      await cacheService.set(key2, value);
      await cacheService.clear();

      final result1 = await cacheService.get<String>(key1, (json) => json as String);
      final result2 = await cacheService.get<String>(key2, (json) => json as String);

      expect(result1, null);
      expect(result2, null);
    });

    test('should get cache statistics', () async {
      const key1 = 'test_key1';
      const key2 = 'test_key2';
      const value = 'test_value';
      final config = CacheConfig(isPersistent: true);

      when(mockDatabaseHelper.query('cache')).thenAnswer((_) async => [
        {
          'key': key1,
          'value': '{"data":"test_value","expiresAt":"${fixedTime.add(const Duration(hours: 1)).toIso8601String()}","createdAt":"${fixedTime.toIso8601String()}","lastAccessedAt":"${fixedTime.toIso8601String()}","accessCount":1}',
        },
        {
          'key': key2,
          'value': '{"data":"test_value","expiresAt":"${fixedTime.add(const Duration(hours: 1)).toIso8601String()}","createdAt":"${fixedTime.toIso8601String()}","lastAccessedAt":"${fixedTime.toIso8601String()}","accessCount":2}',
        },
      ]);

      when(mockDatabaseHelper.insert(
        'cache',
        any,
        conflictResolution: 'REPLACE',
      )).thenAnswer((_) async => 1);

      await cacheService.set(key1, value, config: config);
      await cacheService.set(key2, value, config: config);

      final stats = await cacheService.getStats();

      expect(stats['volatile'], 2);
      expect(stats['persistent'], 2);
      expect(stats['total'], 4);
      expect(stats['total_access_count'], 3);
    });

    test('should handle complex objects', () async {
      const key = 'test_fortune';
      final fortune = Fortune(
        id: '123456789',
        type: FortuneType.daily,
        title: '今日運勢',
        score: 85,
        description: '今天是個好日子',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
        luckyTimes: const ['早上', '下午'],
        luckyDirections: const ['東', '南'],
        luckyColors: const ['紅', '黃'],
        luckyNumbers: const [1, 8],
        suggestions: const ['多運動', '早睡早起'],
        warnings: const ['避免熬夜'],
      );

      await cacheService.set(key, fortune);
      final result = await cacheService.get<Fortune>(
        key,
        (json) => Fortune.fromJson(json as Map<String, dynamic>),
      );

      expect(result?.id, fortune.id);
      expect(result?.type, fortune.type);
      expect(result?.score, fortune.score);
    });

    test('should handle cache expiration', () async {
      const key = 'test_key';
      const value = 'test_value';
      final config = CacheConfig(expiration: const Duration(milliseconds: 100));

      await cacheService.set(key, value, config: config);
      await Future.delayed(const Duration(milliseconds: 150));
      final result = await cacheService.get<String>(key, (json) => json as String);

      expect(result, null);
    });

    test('should enforce max items limit', () async {
      const maxItems = 2;
      final config = CacheConfig(maxItems: maxItems);

      when(mockDatabaseHelper.delete(
        'cache',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 1);

      for (var i = 0; i < maxItems + 1; i++) {
        await cacheService.set('key$i', 'value$i', config: config);
      }

      final result = await cacheService.get<String>('key0', (json) => json as String);
      expect(result, null);
    });

    test('should handle database errors gracefully', () async {
      const key = 'test_key';
      const value = 'test_value';
      final config = CacheConfig(isPersistent: true);

      when(mockDatabaseHelper.query(
        'cache',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      final result = await cacheService.get<String>(key, (json) => json as String, config: config);
      expect(result, null);
    });
  });
} 