import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/cache_service.dart';
import 'package:all_lucky/core/services/cache_manager.dart';
import 'package:all_lucky/core/repositories/almanac_repository.dart';
import 'package:all_lucky/core/repositories/fortune_repository.dart';

@GenerateMocks([
  CacheService,
  AlmanacRepository,
  FortuneRepository,
])
void main() {
  late MockCacheService mockCacheService;
  late MockAlmanacRepository mockAlmanacRepository;
  late MockFortuneRepository mockFortuneRepository;
  late CacheManager cacheManager;

  setUp(() {
    mockCacheService = MockCacheService();
    mockAlmanacRepository = MockAlmanacRepository();
    mockFortuneRepository = MockFortuneRepository();
    cacheManager = CacheManager(
      mockAlmanacRepository,
      mockFortuneRepository,
      mockCacheService,
    );
  });

  group('CacheManager', () {
    test('清理過期緩存應該調用所有相關方法', () async {
      // 準備
      when(mockAlmanacRepository.clearExpiredCache())
          .thenAnswer((_) async {});
      when(mockFortuneRepository.clearExpiredCache())
          .thenAnswer((_) async {});
      when(mockCacheService.clear())
          .thenAnswer((_) async {});

      // 執行
      await cacheManager.clearExpiredCache();

      // 驗證
      verify(mockAlmanacRepository.clearExpiredCache()).called(1);
      verify(mockFortuneRepository.clearExpiredCache()).called(1);
      verify(mockCacheService.clear()).called(1);
    });

    test('獲取緩存統計應該返回所有緩存統計信息', () {
      // 準備
      when(mockCacheService.getStats()).thenReturn({
        'hits': 100,
        'misses': 20,
      });
      when(mockAlmanacRepository.getCacheStats()).thenReturn({
        'hits': 50,
        'misses': 10,
      });
      when(mockFortuneRepository.getCacheStats()).thenReturn({
        'hits': 30,
        'misses': 5,
      });

      // 執行
      final stats = cacheManager.getCacheStats();

      // 驗證
      expect(stats['memory']['hits'], equals(100));
      expect(stats['database']['almanac']['hits'], equals(50));
      expect(stats['database']['fortune']['hits'], equals(30));
    });

    test('清理所有緩存應該調用所有清理方法', () async {
      // 準備
      when(mockAlmanacRepository.clearAllCache())
          .thenAnswer((_) async {});
      when(mockFortuneRepository.clearAllCache())
          .thenAnswer((_) async {});
      when(mockCacheService.clear())
          .thenAnswer((_) async {});

      // 執行
      await cacheManager.clearAllCache();

      // 驗證
      verify(mockAlmanacRepository.clearAllCache()).called(1);
      verify(mockFortuneRepository.clearAllCache()).called(1);
      verify(mockCacheService.clear()).called(1);
    });

    test('清理緩存失敗時應該拋出異常', () async {
      // 準備
      when(mockAlmanacRepository.clearAllCache())
          .thenThrow(Exception('清理失敗'));

      // 驗證
      expect(
        () => cacheManager.clearAllCache(),
        throwsException,
      );
    });
  });
} 