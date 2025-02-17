import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/core/models/fortune.dart';
import '../../lib/core/models/compass_direction.dart';
import '../../lib/core/services/filter_service.dart';
import '../../lib/core/services/fortune_direction_service.dart';
import '../../lib/ui/widgets/compass_widget.dart';
import 'package:all_lucky/ui/screens/home/home_screen.dart';
import 'package:all_lucky/core/services/fortune_service.dart';
import 'package:all_lucky/core/services/scene_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FortuneService, SceneService])
void main() {
  group('性能測試', () {
    late ProviderContainer container;
    late FilterService filterService;
    late FortuneDirectionService fortuneDirectionService;
    late MockFortuneService mockFortuneService;
    late MockSceneService mockSceneService;

    setUp(() {
      container = ProviderContainer();
      fortuneDirectionService = container.read(fortuneDirectionProvider);
      filterService = container.read(filterServiceProvider);
      mockFortuneService = MockFortuneService();
      mockSceneService = MockSceneService();
    });

    tearDown(() {
      container.dispose();
    });

    test('過濾大量運勢數據的性能', () {
      final stopwatch = Stopwatch()..start();
      
      // 生成1000條測試數據
      final fortunes = List.generate(1000, (index) => Fortune(
        id: index.toString(),
        type: ['學習', '事業', '財運', '人際'][index % 4],
        score: 60 + (index % 41), // 60-100的分數
        description: '測試運勢 $index',
        recommendations: ['測試建議'],
        date: DateTime.now(),
      ));

      // 測試過濾性能
      final filtered = filterService.filterFortunes(
        fortunes,
        CompassDirection.fromDegrees(90),
        DateTime.now(),
        minScore: 80,
        types: ['學習', '事業'],
      );

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 應在100毫秒內完成
      expect(filtered.length, greaterThan(0));

      // 測試緩存性能
      stopwatch.reset();
      stopwatch.start();
      final cachedResult = filterService.filterFortunes(
        fortunes,
        CompassDirection.fromDegrees(90),
        DateTime.now(),
        minScore: 80,
        types: ['學習', '事業'],
      );
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(10)); // 緩存應在10毫秒內返回
      expect(cachedResult, equals(filtered));
    });

    testWidgets('指南針組件渲染性能', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                luckyDirections: const ['東', '南'],
                size: 300,
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // 首次渲染應在500毫秒內完成

      // 測試動畫性能
      stopwatch.reset();
      stopwatch.start();
      
      // 模擬30幀的旋轉動畫
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 約60fps
      }

      stopwatch.stop();
      final averageFrameTime = stopwatch.elapsedMilliseconds / 30;
      expect(averageFrameTime, lessThan(16)); // 每幀應在16毫秒內完成以保持60fps
    });

    test('方位計算性能', () {
      final stopwatch = Stopwatch()..start();
      
      // 測試1000次方位計算
      for (int i = 0; i < 1000; i++) {
        final fortune = Fortune(
          id: i.toString(),
          type: '學習',
          score: 85,
          description: '測試運勢',
          recommendations: ['測試'],
          date: DateTime.now(),
        );

        final direction = CompassDirection.fromDegrees(i % 360);
        final advice = fortuneDirectionService.getFullDirectionAdvice(
          fortune,
          direction,
          DateTime.now(),
        );

        expect(advice, isNotEmpty);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1000次計算應在1秒內完成
    });

    test('內存使用測試', () {
      final initialCache = filterService.filterFortunes(
        List.generate(100, (index) => Fortune(
          id: index.toString(),
          type: '學習',
          score: 85,
          description: '測試運勢',
          recommendations: ['測試'],
          date: DateTime.now(),
        )),
        CompassDirection.fromDegrees(90),
        DateTime.now(),
      );

      // 測試緩存限制
      for (int i = 0; i < 20; i++) {
        final result = filterService.filterFortunes(
          List.generate(100, (index) => Fortune(
            id: '${i}_$index',
            type: '學習',
            score: 85,
            description: '測試運勢',
            recommendations: ['測試'],
            date: DateTime.now(),
          )),
          CompassDirection.fromDegrees(90),
          DateTime.now(),
        );

        expect(result, isNotNull);
      }

      // 驗證初始結果是否被清除（因為超出緩存限制）
      final newResult = filterService.filterFortunes(
        List.generate(100, (index) => Fortune(
          id: index.toString(),
          type: '學習',
          score: 85,
          description: '測試運勢',
          recommendations: ['測試'],
          date: DateTime.now(),
        )),
        CompassDirection.fromDegrees(90),
        DateTime.now(),
      );

      expect(newResult, isNot(equals(initialCache)));
    });
  });

  group('應用性能測試', () {
    testWidgets('首頁載入時間測試', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // 等待首次渲染完成
      await tester.pumpAndSettle();

      stopwatch.stop();
      
      // 首頁載入時間應該在1秒以內
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('頁面切換性能測試', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // 點擊底部導航欄切換頁面
      await tester.tap(find.byIcon(Icons.explore));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // 頁面切換時間應該在500毫秒以內
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('滾動性能測試', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // 執行滾動操作
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -300),
        3000,
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // 滾動操作應該在16毫秒內完成（保持60FPS）
      expect(stopwatch.elapsedMilliseconds ~/ tester.binding.window.devicePixelRatio,
          lessThan(16));
    });

    testWidgets('內存使用測試', (tester) async {
      // 記錄初始內存使用
      final initialMemory = tester.binding.currentTestingEngine!.rasterizer!.lastFrame!.layerTree!.estimateMaxMemoryUsage();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 記錄最終內存使用
      final finalMemory = tester.binding.currentTestingEngine!.rasterizer!.lastFrame!.layerTree!.estimateMaxMemoryUsage();

      // 內存增長不應超過50MB
      expect(finalMemory - initialMemory, lessThan(50 * 1024 * 1024));
    });

    testWidgets('圖片載入性能測試', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // 等待所有圖片載入完成
      await tester.pumpAndSettle();

      stopwatch.stop();

      // 圖片載入時間應該在2秒以內
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('動畫性能測試', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // 觸發動畫
      await tester.tap(find.byType(FloatingActionButton));
      
      // 監測動畫幀數
      int frameCount = 0;
      while (tester.binding.hasScheduledFrame) {
        await tester.pump();
        frameCount++;
      }

      stopwatch.stop();

      // 動畫應該保持60FPS
      final fps = frameCount / (stopwatch.elapsedMilliseconds / 1000);
      expect(fps, greaterThanOrEqualTo(60));
    });
  });
} 