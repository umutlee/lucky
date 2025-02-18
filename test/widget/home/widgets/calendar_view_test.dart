import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/home/widgets/calendar_view.dart';
import 'package:all_lucky/core/services/calendar_service.dart';
import 'package:all_lucky/core/models/lunar_date.dart';
import 'package:all_lucky/core/models/solar_term.dart';
import 'package:all_lucky/core/models/daily_activities.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([CalendarService])
void main() {
  group('萬年曆視圖測試', () {
    late MockCalendarService mockCalendarService;

    setUp(() {
      mockCalendarService = MockCalendarService();

      // 設置基本的 mock 回應
      when(mockCalendarService.getLunarDate(any))
          .thenAnswer((_) async => const LunarDate(
                heavenlyStem: '甲',
                earthlyBranch: '辰',
                dayZhi: '寅',
                timeZhi: '子',
                wuXing: '木',
                positions: ['東', '南'],
                year: 2024,
                month: 2,
                day: 17,
                isLeapMonth: false,
              ));

      when(mockCalendarService.getSolarTerm(any))
          .thenAnswer((_) async => SolarTerm(
                name: '雨水',
                date: DateTime(2024, 2, 17),
                description: '雨水節氣，萬物復甦',
                element: '木',
              ));

      when(mockCalendarService.getDailyActivities(any))
          .thenAnswer((_) async => DailyActivities(
                date: DateTime(2024, 2, 17),
                goodActivities: ['祈福', '開業'],
                badActivities: ['動土', '安葬'],
              ));

      when(mockCalendarService.getLuckyHours(any))
          .thenAnswer((_) async => ['子時', '午時', '卯時']);
    });

    testWidgets('測試基本渲染', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarServiceProvider.overrideWithValue(mockCalendarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // 驗證日期顯示
      expect(find.text('甲辰年二月十七'), findsOneWidget);
      expect(find.text('雨水'), findsOneWidget);
      expect(find.text('宜：祈福、開業'), findsOneWidget);
      expect(find.text('忌：動土、安葬'), findsOneWidget);
      expect(find.text('吉時：子時、午時、卯時'), findsOneWidget);
    });

    testWidgets('測試日期切換', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarServiceProvider.overrideWithValue(mockCalendarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // 點擊下一天按鈕
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      // 驗證服務調用
      verify(mockCalendarService.getLunarDate(any)).called(2);
      verify(mockCalendarService.getSolarTerm(any)).called(2);
      verify(mockCalendarService.getDailyActivities(any)).called(2);
      verify(mockCalendarService.getLuckyHours(any)).called(2);
    });

    testWidgets('測試節氣顯示', (tester) async {
      when(mockCalendarService.getSolarTerm(any))
          .thenAnswer((_) async => SolarTerm(
                name: '雨水',
                date: DateTime(2024, 2, 17),
                description: '雨水節氣，萬物復甦',
                element: '木',
              ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarServiceProvider.overrideWithValue(mockCalendarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // 驗證節氣顯示
      expect(find.text('雨水'), findsOneWidget);
      expect(find.text('雨水節氣，萬物復甦'), findsOneWidget);
    });

    testWidgets('測試錯誤處理', (tester) async {
      when(mockCalendarService.getLunarDate(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarServiceProvider.overrideWithValue(mockCalendarService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CalendarView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // 驗證錯誤提示
      expect(find.text('無法載入日曆數據'), findsOneWidget);
      expect(find.text('請稍後重試'), findsOneWidget);
    });
  });
} 