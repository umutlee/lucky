import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:all_lucky/app/app.dart';
import 'package:all_lucky/features/home/screens/home_screen.dart';
import 'package:all_lucky/features/fortune/screens/fortune_prediction_screen.dart';

void main() {
  group('渲染性能測試', () {
    late List<Duration> frameTimes;
    
    setUp(() {
      frameTimes = [];
      SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
        for (final timing in timings) {
          final duration = timing.totalSpan;
          frameTimes.add(duration);
        }
      });
    });

    tearDown(() {
      frameTimes.clear();
    });

    double calculateAverageFrameRate() {
      if (frameTimes.isEmpty) return 0;
      final averageDuration = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      return 1000000 / averageDuration.inMicroseconds; // 轉換為每秒幀數
    }

    double calculateJank() {
      if (frameTimes.length < 2) return 0;
      var jankCount = 0;
      for (var i = 1; i < frameTimes.length; i++) {
        if (frameTimes[i].inMilliseconds - frameTimes[i - 1].inMilliseconds > 16) {
          // 如果兩幀之間的間隔超過 16ms (60fps)，視為卡頓
          jankCount++;
        }
      }
      return jankCount / frameTimes.length * 100; // 返回卡頓百分比
    }

    testWidgets('滾動列表渲染性能測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 模擬連續滾動操作
      for (var i = 0; i < 50; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 16)); // 模擬 60fps
      }

      final averageFps = calculateAverageFrameRate();
      final jankPercentage = calculateJank();

      // 平均幀率應該大於 55fps
      expect(averageFps, greaterThan(55));
      // 卡頓率應該小於 5%
      expect(jankPercentage, lessThan(5));
    });

    testWidgets('動畫渲染性能測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 觸發頁面切換動畫
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.fortune));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300)); // 等待動畫完成
        
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      final averageFps = calculateAverageFrameRate();
      final jankPercentage = calculateJank();

      // 動畫過程中的平均幀率應該大於 58fps
      expect(averageFps, greaterThan(58));
      // 卡頓率應該小於 3%
      expect(jankPercentage, lessThan(3));
    });

    testWidgets('運勢卡片渲染性能測試', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FortunePredictionScreen()),
      );
      await tester.pumpAndSettle();

      // 模擬多次運勢卡片動畫
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500)); // 等待卡片動畫
      }

      final averageFps = calculateAverageFrameRate();
      final jankPercentage = calculateJank();

      // 卡片動畫的平均幀率應該大於 56fps
      expect(averageFps, greaterThan(56));
      // 卡頓率應該小於 4%
      expect(jankPercentage, lessThan(4));
    });

    testWidgets('複雜佈局渲染性能測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 模擬在複雜佈局中的操作
      for (var i = 0; i < 20; i++) {
        // 切換不同頁面並觸發重建
        await tester.tap(find.byIcon(Icons.fortune));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // 模擬滾動操作
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      final averageFps = calculateAverageFrameRate();
      final jankPercentage = calculateJank();

      // 複雜操作的平均幀率應該大於 54fps
      expect(averageFps, greaterThan(54));
      // 卡頓率應該小於 6%
      expect(jankPercentage, lessThan(6));
    });
  });
} 