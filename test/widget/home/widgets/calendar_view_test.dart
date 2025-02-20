import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/calendar_service.dart' hide calendarServiceProvider;
import 'package:all_lucky/core/services/error_service.dart' hide errorServiceProvider;
import 'package:all_lucky/core/models/lunar_date.dart';
import 'package:all_lucky/core/models/solar_term.dart';
import 'package:all_lucky/core/models/daily_activities.dart';
import 'package:all_lucky/core/providers/calendar_provider.dart';
import 'package:all_lucky/ui/screens/home/widgets/calendar_view.dart';
import 'package:all_lucky/core/models/app_error.dart';
import 'package:all_lucky/core/utils/logger.dart';

import 'calendar_view_test.mocks.dart';

@GenerateMocks([CalendarService, ErrorService])
void main() {
  late MockCalendarService mockCalendarService;
  late MockErrorService mockErrorService;
  final testDate = DateTime(2024, 3, 15);

  setUp(() {
    mockCalendarService = MockCalendarService();
    mockErrorService = MockErrorService();

    // 設置基本的 mock 回應
    when(mockCalendarService.getLunarDate(any)).thenAnswer((_) async => const LunarDate(
      heavenlyStem: '甲',
      earthlyBranch: '子',
      dayZhi: '寅',
      timeZhi: '午',
      wuXing: '木',
      isLeapMonth: false,
      lunarDay: '初一',
      solarTerm: '立春',
    ));

    when(mockCalendarService.getSolarTerm(any)).thenAnswer((_) async => SolarTerm(
      name: '立春',
      date: DateTime.now(),
    ));

    when(mockCalendarService.getDailyActivities(any)).thenAnswer((_) async => const DailyActivities(
      goodActivities: ['祈福', '開市'],
      badActivities: ['動土', '安葬'],
    ));

    when(mockCalendarService.getLuckyHours(any)).thenAnswer((_) async => ['子時', '午時']);

    when(mockErrorService.handleError(any, any)).thenAnswer((_) async => AppError(
      message: '發生錯誤',
      type: ErrorType.unknown,
      stackTrace: StackTrace.current,
    ));
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        calendarServiceProvider.overrideWithValue(mockCalendarService),
        errorServiceProvider.overrideWithValue(mockErrorService),
        dateProvider.overrideWithValue(testDate),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: CalendarView(),
        ),
      ),
    );
  }

  group('CalendarView 基本功能測試', () {
    testWidgets('應該正確顯示載入狀態', (tester) async {
      final completer = Completer<LunarDate>();
      when(mockCalendarService.getLunarDate(any))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());

      // 驗證載入指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 完成異步操作
      completer.complete(const LunarDate(
        heavenlyStem: '甲',
        earthlyBranch: '子',
        dayZhi: '寅',
        timeZhi: '午',
        wuXing: '木',
        isLeapMonth: false,
        lunarDay: '初一',
        solarTerm: '立春',
      ));
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('應該正確顯示農曆日期', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('甲子年'), findsOneWidget);
      expect(find.text('寅日'), findsOneWidget);
      expect(find.text('午時'), findsOneWidget);
      expect(find.text('初一'), findsOneWidget);
    });

    testWidgets('應該正確顯示節氣信息', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('立春'), findsOneWidget);
    });

    testWidgets('應該正確顯示吉凶活動', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('祈福'), findsOneWidget);
      expect(find.text('開市'), findsOneWidget);
      expect(find.text('動土'), findsOneWidget);
      expect(find.text('安葬'), findsOneWidget);
    });
  });

  group('CalendarView 錯誤處理測試', () {
    testWidgets('網絡錯誤時應該顯示錯誤信息', (tester) async {
      when(mockCalendarService.getLunarDate(any))
          .thenThrow(Exception('網絡連接失敗'));
      
      when(mockErrorService.handleError(any, any))
          .thenAnswer((_) async => AppError(
            message: '載入日曆資料失敗',
            type: ErrorType.network,
            stackTrace: StackTrace.current,
          ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('載入日曆資料失敗'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
    });

    testWidgets('服務器錯誤時應該顯示錯誤信息', (tester) async {
      when(mockCalendarService.getLunarDate(any))
          .thenThrow(Exception('服務器錯誤'));
          
      when(mockErrorService.handleError(any, any))
          .thenAnswer((_) async => AppError(
            message: '服務器錯誤',
            type: ErrorType.server,
            stackTrace: StackTrace.current,
          ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('服務器錯誤'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
    });

    testWidgets('點擊重試按鈕應該重新載入數據', (tester) async {
      // 第一次調用拋出錯誤
      when(mockCalendarService.getLunarDate(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 重新設置 mock 行為
      when(mockCalendarService.getLunarDate(any))
          .thenAnswer((_) async => const LunarDate(
                heavenlyStem: '甲',
                earthlyBranch: '子',
                dayZhi: '寅',
                timeZhi: '午',
                wuXing: '木',
                isLeapMonth: false,
                lunarDay: '初一',
                solarTerm: '立春',
              ));

      // 點擊重試按鈕
      await tester.tap(find.text('重試'));
      await tester.pumpAndSettle();

      expect(find.text('甲子年'), findsOneWidget);
      
      // 驗證服務被調用兩次
      verify(mockCalendarService.getLunarDate(any)).called(2);
    });
  });

  group('CalendarView 邊界情況測試', () {
    testWidgets('閏月應該正確顯示', (tester) async {
      when(mockCalendarService.getLunarDate(any))
          .thenAnswer((_) async => const LunarDate(
                heavenlyStem: '甲',
                earthlyBranch: '子',
                dayZhi: '寅',
                timeZhi: '午',
                wuXing: '木',
                isLeapMonth: true,
                lunarDay: '初一',
                solarTerm: '立春',
              ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('閏'), findsOneWidget);
    });

    testWidgets('無節氣時應該正確顯示', (tester) async {
      when(mockCalendarService.getSolarTerm(any))
          .thenAnswer((_) async => SolarTerm.empty);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('無節氣'), findsOneWidget);
    });

    testWidgets('無吉凶活動時應該正確顯示', (tester) async {
      when(mockCalendarService.getDailyActivities(any))
          .thenAnswer((_) async => const DailyActivities(
                goodActivities: [],
                badActivities: [],
              ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('無'), findsNWidgets(2));
    });
  });

  group('CalendarView 性能測試', () {
    testWidgets('多次重建不應該觸發多餘的服務調用', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 重建 widget 多次
      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
      }

      // 驗證每個服務只被調用一次
      verify(mockCalendarService.getLunarDate(any)).called(1);
      verify(mockCalendarService.getSolarTerm(any)).called(1);
      verify(mockCalendarService.getDailyActivities(any)).called(1);
      verify(mockCalendarService.getLuckyHours(any)).called(1);
    });

    testWidgets('快速點擊重試按鈕應該防抖', (tester) async {
      when(mockCalendarService.getLunarDate(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 快速點擊重試按鈕多次
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('重試'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // 由於防抖，服務應該只被調用兩次（初始加載和一次重試）
      verify(mockCalendarService.getLunarDate(any)).called(2);
    });
  });
} 