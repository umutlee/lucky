import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/presentation/pages/cache_stats_page.dart';
import 'package:all_lucky/core/services/cache_manager.dart';

class MockCacheManager extends Mock implements CacheManager {
  @override
  Map<String, dynamic> getCacheStats() {
    return {
      'memory': {
        'hits': 100,
        'misses': 20,
        'hitRate': 83,
      },
      'database': {
        'almanac': {
          'hits': 50,
          'misses': 10,
          'hitRate': 83,
        },
        'fortune': {
          'hits': 30,
          'misses': 5,
          'hitRate': 85,
        },
      },
    };
  }
}

void main() {
  late MockCacheManager mockCacheManager;

  setUp(() {
    mockCacheManager = MockCacheManager();
  });

  testWidgets('應該正確顯示緩存統計信息', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheManagerProvider.overrideWithValue(mockCacheManager),
        ],
        child: const MaterialApp(
          home: CacheStatsPage(),
        ),
      ),
    );

    // 驗證標題
    expect(find.text('緩存統計'), findsOneWidget);

    // 驗證總覽卡片
    expect(find.text('緩存總覽'), findsOneWidget);
    expect(find.text('總命中率'), findsOneWidget);
    expect(find.text('命中次數'), findsNWidgets(4)); // 總覽 + 3個詳細卡片

    // 驗證詳細卡片
    expect(find.text('內存緩存'), findsOneWidget);
    expect(find.text('黃曆緩存'), findsOneWidget);
    expect(find.text('運勢緩存'), findsOneWidget);
  });

  testWidgets('應該能夠清理緩存', (tester) async {
    when(mockCacheManager.clearAllCache())
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheManagerProvider.overrideWithValue(mockCacheManager),
        ],
        child: const MaterialApp(
          home: CacheStatsPage(),
        ),
      ),
    );

    // 打開選項菜單
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // 點擊清理所有緩存
    await tester.tap(find.text('清理所有緩存'));
    await tester.pumpAndSettle();

    // 驗證清理方法被調用
    verify(mockCacheManager.clearAllCache()).called(1);

    // 驗證提示信息
    expect(find.text('緩存已清理'), findsOneWidget);
  });

  testWidgets('清理失敗時應該顯示錯誤信息', (tester) async {
    when(mockCacheManager.clearAllCache())
        .thenThrow(Exception('清理失敗'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheManagerProvider.overrideWithValue(mockCacheManager),
        ],
        child: const MaterialApp(
          home: CacheStatsPage(),
        ),
      ),
    );

    // 打開選項菜單
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // 點擊清理所有緩存
    await tester.tap(find.text('清理所有緩存'));
    await tester.pumpAndSettle();

    // 驗證錯誤信息
    expect(find.text('清理失敗: Exception: 清理失敗'), findsOneWidget);
  });
} 