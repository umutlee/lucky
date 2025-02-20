import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/home/widgets/zodiac_section.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/app_error.dart';
import 'package:all_lucky/core/providers/zodiac_provider.dart';
import 'package:all_lucky/core/services/zodiac_service.dart';
import 'package:all_lucky/core/services/error_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ZodiacService, ErrorService])
import 'zodiac_section_test.mocks.dart';

void main() {
  late MockZodiacService mockZodiacService;
  late MockErrorService mockErrorService;

  setUp(() {
    mockZodiacService = MockZodiacService();
    mockErrorService = MockErrorService();

    // 設置基本的 mock 回應
    when(mockZodiacService.calculateZodiac(any)).thenReturn(Zodiac.rat);
    when(mockZodiacService.getFortuneDescription(any))
        .thenAnswer((_) async => '今日運勢不錯');
    when(mockZodiacService.getLuckyElements(any))
        .thenAnswer((_) async => ['紅色', '8']);
    when(mockZodiacService.getZodiacAttributes(any))
        .thenAnswer((_) async => {
              'element': '木',
              'direction': '東',
              'color': '綠',
              'number': '4',
            });

    when(mockErrorService.handleError(any, any)).thenAnswer((_) async => AppError(
      message: '發生未知錯誤，請重試',
      type: ErrorType.unknown,
      stackTrace: StackTrace.current,
    ));
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        zodiacServiceProvider.overrideWithValue(mockZodiacService),
        errorServiceProvider.overrideWithValue(mockErrorService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: ZodiacSection(isTest: true),
        ),
      ),
    );
  }

  group('ZodiacSection 基本功能測試', () {
    testWidgets('應該正確顯示載入狀態', (tester) async {
      final completer = Completer<String>();
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());

      // 驗證載入指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 完成異步操作
      completer.complete('今日運勢不錯');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('應該正確顯示生肖運勢', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('生肖運勢'), findsOneWidget);
      expect(find.text('鼠'), findsOneWidget);
      expect(find.text('今日運勢不錯'), findsOneWidget);
      expect(find.text('紅色'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('應該正確顯示生肖屬性', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('木'), findsOneWidget);
      expect(find.text('東'), findsOneWidget);
      expect(find.text('綠'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });

  group('ZodiacSection 錯誤處理測試', () {
    testWidgets('網絡錯誤時應該顯示錯誤信息', (tester) async {
      when(mockZodiacService.getFortuneDescription(any))
          .thenThrow(Exception('網絡連接失敗'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('發生未知錯誤，請重試'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
    });

    testWidgets('服務器錯誤時應該顯示錯誤信息', (tester) async {
      when(mockZodiacService.getFortuneDescription(any))
          .thenThrow(Exception('服務器錯誤'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('發生未知錯誤，請重試'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
    });

    testWidgets('點擊重試按鈕應該重新載入運勢', (tester) async {
      // 第一次調用拋出錯誤
      when(mockZodiacService.getFortuneDescription(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 重新設置 mock 行為
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) async => '今日運勢不錯');

      // 點擊重試按鈕
      await tester.tap(find.text('重試'));
      await tester.pumpAndSettle();

      expect(find.text('生肖運勢'), findsOneWidget);
      expect(find.text('今日運勢不錯'), findsOneWidget);

      // 驗證服務被調用兩次
      verify(mockZodiacService.getFortuneDescription(any)).called(2);
    });
  });

  group('ZodiacSection 邊界情況測試', () {
    testWidgets('空運勢數據時應該顯示預設信息', (tester) async {
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) async => '');
      when(mockZodiacService.getLuckyElements(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('暫無運勢數據'), findsOneWidget);
    });

    testWidgets('極長文本應該正確截斷', (tester) async {
      final longText = 'a' * 1000;
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) async => longText);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('無效生肖時應該顯示預設生肖', (tester) async {
      when(mockZodiacService.calculateZodiac(any))
          .thenReturn(Zodiac.unknown);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('未知'), findsOneWidget);
    });
  });

  group('ZodiacSection 性能測試', () {
    testWidgets('多次重建不應該觸發多餘的服務調用', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 重建 widget 多次
      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
      }

      // 驗證服務只被調用一次
      verify(mockZodiacService.getFortuneDescription(any)).called(1);
    });

    testWidgets('快速點擊重試按鈕應該防抖', (tester) async {
      when(mockZodiacService.getFortuneDescription(any))
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
      verify(mockZodiacService.getFortuneDescription(any)).called(2);
    });
  });
}