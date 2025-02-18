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

    when(mockErrorService.handleError(any, any)).thenReturn(AppError(
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

  group('ZodiacSection 測試', () {
    testWidgets('應該正確顯示載入狀態', (tester) async {
      // 使用 Completer 來控制異步操作
      final completer = Completer<String>();
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());

      // 驗證載入指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 完成異步操作
      completer.complete('今日運勢不錯');
      await tester.pumpAndSettle();
    });

    testWidgets('應該正確顯示錯誤狀態', (tester) async {
      when(mockZodiacService.getFortuneDescription(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('發生未知錯誤，請重試'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
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
    });
  });
} 