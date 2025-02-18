import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/calendar_service.dart';
import 'package:all_lucky/core/services/error_service.dart';
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

    when(mockErrorService.handleError(any, any)).thenReturn(AppError(
      message: '發生錯誤',
      type: ErrorType.unknown,
      originalError: Exception('測試錯誤'),
    ));
  });

  testWidgets('CalendarView 應該正確顯示日曆信息', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarStateProvider.overrideWith((ref) => CalendarNotifier(
            mockCalendarService,
            mockErrorService,
          )),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CalendarView(),
          ),
        ),
      ),
    );

    // 等待異步操作完成
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // 驗證基本 UI 元素存在
    expect(find.text('農曆 甲子年初一'), findsOneWidget);
    expect(find.text('立春'), findsOneWidget);
    expect(find.text('宜'), findsOneWidget);
    expect(find.text('忌'), findsOneWidget);
    expect(find.text('吉時'), findsOneWidget);

    // 驗證活動列表
    expect(find.text('祈福'), findsOneWidget);
    expect(find.text('開市'), findsOneWidget);
    expect(find.text('動土'), findsOneWidget);
    expect(find.text('安葬'), findsOneWidget);

    // 驗證吉時
    expect(find.text('子時'), findsOneWidget);
    expect(find.text('午時'), findsOneWidget);
  });

  testWidgets('CalendarView 應該處理錯誤狀態', (tester) async {
    // 模擬錯誤情況
    when(mockCalendarService.getLunarDate(any)).thenThrow(Exception('測試錯誤'));
    when(mockErrorService.handleError(any, any)).thenReturn(AppError(
      message: '發生錯誤',
      type: ErrorType.unknown,
      originalError: Exception('測試錯誤'),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarStateProvider.overrideWith((ref) => CalendarNotifier(
            mockCalendarService,
            mockErrorService,
          )),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CalendarView(),
          ),
        ),
      ),
    );

    // 等待異步操作完成
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // 驗證錯誤 UI
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('發生未知錯誤，請重試'), findsOneWidget);
    expect(find.text('重試'), findsOneWidget);

    // 測試重試按鈕
    await tester.tap(find.text('重試'));
    await tester.pump();

    // 驗證重試調用
    verify(mockCalendarService.getLunarDate(any)).called(2);
  });

  testWidgets('CalendarView 應該處理加載狀態', (tester) async {
    // 使用 Completer 來控制異步操作
    final completer = Completer<LunarDate>();
    when(mockCalendarService.getLunarDate(any)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarStateProvider.overrideWith((ref) => CalendarNotifier(
            mockCalendarService,
            mockErrorService,
          )),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CalendarView(),
          ),
        ),
      ),
    );

    // 驗證加載指示器
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 完成加載
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

    // 等待異步操作完成
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // 驗證內容已加載
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('農曆 甲子年初一'), findsOneWidget);
  });
} 