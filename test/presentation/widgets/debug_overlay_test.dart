import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/presentation/widgets/debug_overlay.dart';
import 'package:all_lucky/core/services/cache_manager.dart';
import 'package:go_router/go_router.dart';

class MockCacheManager extends Mock implements CacheManager {
  @override
  Map<String, dynamic> getCacheStats() {
    return {
      'memory': {
        'hitRate': 85,
      },
    };
  }
}

void main() {
  late MockCacheManager mockCacheManager;

  setUp(() {
    mockCacheManager = MockCacheManager();
  });

  testWidgets('應該正確顯示緩存命中率', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheManagerProvider.overrideWithValue(mockCacheManager),
        ],
        child: MaterialApp(
          home: Stack(
            children: const [
              Scaffold(),
              DebugOverlay(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('緩存命中率: 85%'), findsOneWidget);
  });

  testWidgets('點擊應該導航到緩存統計頁面', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Stack(
            children: [
              Scaffold(),
              DebugOverlay(),
            ],
          ),
        ),
        GoRoute(
          path: '/cache-stats',
          builder: (context, state) => const Scaffold(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheManagerProvider.overrideWithValue(mockCacheManager),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(router.location, '/cache-stats');
  });
} 