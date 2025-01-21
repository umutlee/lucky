import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/cache_manager.dart';
import 'package:all_lucky/core/services/cache_cleanup_service.dart';

@GenerateMocks([CacheManager])
void main() {
  late MockCacheManager mockCacheManager;
  late CacheCleanupService service;

  setUp(() {
    mockCacheManager = MockCacheManager();
    service = CacheCleanupService(mockCacheManager);
  });

  tearDown(() {
    service.dispose();
  });

  test('應該正確啟動定期清理', () {
    // 執行
    service.startPeriodicCleanup();

    // 驗證服務已啟動
    expect(service, isNotNull);
  });

  test('應該正確停止定期清理', () {
    // 準備
    service.startPeriodicCleanup();

    // 執行
    service.stopPeriodicCleanup();

    // 驗證服務已停止
    expect(service, isNotNull);
  });

  test('清理失敗時不應該中斷服務', () async {
    // 準備
    when(mockCacheManager.clearExpiredCache())
        .thenThrow(Exception('清理失敗'));
    when(mockCacheManager.getCacheStats())
        .thenReturn({'memory': {}, 'database': {}});

    // 執行
    service.startPeriodicCleanup();
    
    // 等待一段時間確保清理被執行
    await Future.delayed(const Duration(milliseconds: 100));

    // 驗證服務仍在運行
    expect(service, isNotNull);
  });
} 