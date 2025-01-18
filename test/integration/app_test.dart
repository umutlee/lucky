import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/main.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/notification_settings.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/core/services/solar_term_service.dart';
import 'package:all_lucky/core/services/lucky_day_service.dart';
import 'package:all_lucky/core/providers/notification_settings_provider.dart';
import 'package:all_lucky/core/providers/filter_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  NotificationService,
  SolarTermService,
  LuckyDayService,
])
void main() {
  late MockNotificationService mockNotificationService;
  late MockSolarTermService mockSolarTermService;
  late MockLuckyDayService mockLuckyDayService;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockSolarTermService = MockSolarTermService();
    mockLuckyDayService = MockLuckyDayService();
  });

  testWidgets('應用程序啟動流程測試', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          solarTermServiceProvider.overrideWithValue(mockSolarTermService),
          luckyDayServiceProvider.overrideWithValue(mockLuckyDayService),
        ],
        child: const MyApp(),
      ),
    );

    // 等待初始化完成
    await tester.pumpAndSettle();

    // 驗證初始化流程
    verify(mockNotificationService.initialize()).called(1);
  });

  testWidgets('運勢篩選功能測試', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          solarTermServiceProvider.overrideWithValue(mockSolarTermService),
          luckyDayServiceProvider.overrideWithValue(mockLuckyDayService),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 打開篩選面板
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // 選擇運勢類型
    await tester.tap(find.text('每日運勢'));
    await tester.pumpAndSettle();

    // 調整分數範圍
    final slider = find.byType(RangeSlider);
    expect(slider, findsOneWidget);

    // 選擇吉日
    await tester.tap(find.text('只顯示吉日'));
    await tester.pumpAndSettle();

    // 應用篩選條件
    await tester.tap(find.text('應用'));
    await tester.pumpAndSettle();
  });

  testWidgets('通知設置功能測試', (tester) async {
    when(mockNotificationService.initialize())
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          solarTermServiceProvider.overrideWithValue(mockSolarTermService),
          luckyDayServiceProvider.overrideWithValue(mockLuckyDayService),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 打開設置頁面
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // 切換每日運勢通知
    await tester.tap(find.text('每日運勢提醒').first);
    await tester.pumpAndSettle();

    // 切換節氣提醒
    await tester.tap(find.text('節氣提醒').first);
    await tester.pumpAndSettle();

    // 切換吉日提醒
    await tester.tap(find.text('吉日提醒').first);
    await tester.pumpAndSettle();

    // 驗證通知設置更新
    verify(mockNotificationService.cancelAll()).called(1);
  });

  testWidgets('錯誤處理測試', (tester) async {
    when(mockNotificationService.initialize())
        .thenThrow(NotificationException('測試錯誤', 'TEST_ERROR'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          solarTermServiceProvider.overrideWithValue(mockSolarTermService),
          luckyDayServiceProvider.overrideWithValue(mockLuckyDayService),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 應顯示錯誤提示
    expect(find.text('初始化失敗'), findsOneWidget);
    expect(find.text('測試錯誤'), findsOneWidget);
  });

  testWidgets('性能測試 - 列表滾動', (tester) async {
    final fortunes = List.generate(100, (index) {
      return Fortune(
        type: FortuneType.daily,
        score: (index % 100).toDouble(),
        date: DateTime.now().add(Duration(days: index % 30)),
        isLuckyDay: index % 2 == 0,
        luckyDirections: ['東'],
        suitableActivities: ['讀書'],
        description: '測試 $index',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotificationService),
          solarTermServiceProvider.overrideWithValue(mockSolarTermService),
          luckyDayServiceProvider.overrideWithValue(mockLuckyDayService),
          fortuneListProvider.overrideWithValue(fortunes),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 測試列表滾動性能
    final startTime = DateTime.now();
    await tester.fling(
      find.byType(ListView),
      const Offset(0, -500),
      1000,
    );
    await tester.pumpAndSettle();
    final duration = DateTime.now().difference(startTime);

    expect(duration.inMilliseconds, lessThan(500)); // 滾動應在500毫秒內完成
  });
} 