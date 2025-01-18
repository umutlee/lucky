import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/core/models/fortune.dart';
import '../../lib/core/models/compass_direction.dart';
import '../../lib/core/services/filter_service.dart';
import '../../lib/core/services/fortune_direction_service.dart';
import '../../lib/ui/widgets/compass_widget.dart';

void main() {
  group('性能測試', () {
    late ProviderContainer container;
    late FilterService filterService;
    late FortuneDirectionService fortuneDirectionService;

    setUp(() {
      container = ProviderContainer();
      fortuneDirectionService = container.read(fortuneDirectionProvider);
      filterService = container.read(filterServiceProvider);
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
} 