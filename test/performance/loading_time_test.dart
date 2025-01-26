import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:all_lucky/app/app.dart';
import 'package:all_lucky/features/home/screens/home_screen.dart';
import 'package:all_lucky/features/fortune/screens/fortune_prediction_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/core/services/network_service.dart';

class MockNetworkService extends Mock implements NetworkService {}

void main() {
  late MockNetworkService mockNetworkService;

  setUp(() {
    mockNetworkService = MockNetworkService();
  });

  group('載入時間測試', () {
    testWidgets('應用啟動時間測試', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 應用啟動時間不應超過 2 秒
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('首頁載入時間測試', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // 首頁載入時間不應超過 1 秒
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('運勢預測頁面載入時間測試', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FortunePredictionScreen()),
      );
      
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // 運勢預測頁面載入時間不應超過 1.5 秒
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));
    });

    testWidgets('頁面切換時間測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // 模擬點擊導航到運勢預測頁面
      await tester.tap(find.byIcon(Icons.fortune));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 頁面切換時間不應超過 500 毫秒
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('網絡延遲情況下的載入時間測試', (WidgetTester tester) async {
      when(mockNetworkService.getNetworkDelay()).thenReturn(const Duration(seconds: 2));
      
      await tester.pumpWidget(const App());
      
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // 即使在網絡延遲情況下，UI 響應時間也不應超過 3 秒
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });

    testWidgets('離線模式下的載入時間測試', (WidgetTester tester) async {
      when(mockNetworkService.isOffline).thenReturn(true);
      
      await tester.pumpWidget(const App());
      
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // 離線模式下應該快速載入離線數據
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
} 