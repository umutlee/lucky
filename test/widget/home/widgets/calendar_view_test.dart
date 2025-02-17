import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/home/widgets/calendar_view.dart';
import 'package:all_lucky/core/services/lunar_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([LunarService])
void main() {
  group('萬年曆視圖測試', () {
    late MockLunarService mockLunarService;

    setUp(() {
      mockLunarService = MockLunarService();
    });

    testWidgets('測試基本渲染', (tester) async {
      final today = DateTime.now();
      
      when(mockLunarService.getSolarDate(today))
          .thenReturn('2024年2月17日');
      when(mockLunarService.getLunarDate(today))
          .thenReturn('甲辰年正月初八');
      when(mockLunarService.getSolarTerm(today))
          .thenReturn('雨水');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lunarServiceProvider.overrideWithValue(mockLunarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      // 驗證日期顯示
      expect(find.text('2024年2月17日'), findsOneWidget);
      expect(find.text('甲辰年正月初八'), findsOneWidget);
      expect(find.text('雨水'), findsOneWidget);
    });

    testWidgets('測試日期切換', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lunarServiceProvider.overrideWithValue(mockLunarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      // 點擊下一天按鈕
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      // 驗證日期更新
      verify(mockLunarService.getSolarDate(any)).called(2);
      verify(mockLunarService.getLunarDate(any)).called(2);
      verify(mockLunarService.getSolarTerm(any)).called(2);
    });

    testWidgets('測試節氣顯示', (tester) async {
      when(mockLunarService.getSolarTerm(any))
          .thenReturn('雨水');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lunarServiceProvider.overrideWithValue(mockLunarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      // 驗證節氣顯示
      expect(find.text('雨水'), findsOneWidget);
    });
  });
} 