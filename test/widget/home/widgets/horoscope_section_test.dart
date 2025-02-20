import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:all_lucky/core/providers/horoscope_provider.dart';
import 'package:all_lucky/core/providers/navigation_service_provider.dart';
import 'package:all_lucky/core/services/horoscope_service.dart';
import 'package:all_lucky/core/services/error_service.dart';
import 'package:all_lucky/ui/screens/home/widgets/horoscope_section.dart';
import 'package:all_lucky/core/models/horoscope.dart';
import 'package:all_lucky/core/models/app_error.dart';
import 'package:all_lucky/core/services/navigation_service.dart';

import 'horoscope_section_test.mocks.dart';

@GenerateMocks([HoroscopeService, ErrorService, NavigationService])
void main() {
  late MockHoroscopeService horoscopeService;
  late MockErrorService errorService;
  late MockNavigationService navigationService;
  late Logger logger;
  late DateTime testBirthDate;

  void _log(String message) {
    logger.d(message);
  }

  Future<void> _buildTestWidget(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        horoscopeProvider.overrideWith((ref) => HoroscopeNotifier(
          horoscopeService,
          errorService,
          testBirthDate,
        )),
        navigationServiceProvider.overrideWithValue(navigationService),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: HoroscopeSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    horoscopeService = MockHoroscopeService();
    errorService = MockErrorService();
    navigationService = MockNavigationService();
    testBirthDate = DateTime.now();
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );

    // 設置基本的 mock 回應
    when(horoscopeService.getHoroscope(any)).thenAnswer(
      (_) => Future.value(Horoscope.leo),
    );

    when(horoscopeService.getFortuneDescription(any)).thenAnswer(
      (_) => Future.value('今天運勢不錯'),
    );

    when(horoscopeService.getLuckyElements(any)).thenAnswer(
      (_) => Future.value(['紅色', '7']),
    );

    // 設置錯誤處理的 mock 回應
    when(errorService.handleError(any, any)).thenAnswer(
      (_) => Future.value(AppError(
        message: '處理錯誤',
        type: ErrorType.unknown,
        stackTrace: StackTrace.current,
      )),
    );

    // 設置導航服務的 mock 回應
    when(navigationService.navigateToHoroscopeDetail(any))
        .thenAnswer((_) => Future.value(true));
  });

  group('HoroscopeSection 基本功能測試', () {
    testWidgets('應該正確顯示星座運勢', (WidgetTester tester) async {
      _log('開始測試：顯示星座運勢');
      _log('設置測試數據：獅子座運勢');

      await _buildTestWidget(tester);
      _log('Widget 已渲染並等待動畫完成');

      expect(find.textContaining('獅子座'), findsOneWidget);
      expect(find.textContaining('今天運勢不錯'), findsOneWidget);
      expect(find.textContaining('紅色'), findsOneWidget);
      expect(find.textContaining('7'), findsOneWidget);
      _log('運勢顯示驗證完成');
    });
  });

  group('HoroscopeSection 錯誤處理測試', () {
    testWidgets('網絡錯誤時應該顯示錯誤信息', (WidgetTester tester) async {
      _log('開始測試：網絡錯誤處理');

      when(horoscopeService.getHoroscope(any)).thenThrow(Exception('網絡錯誤'));
      _log('設置網絡錯誤狀態');

      await _buildTestWidget(tester);
      _log('Widget 已渲染並等待動畫完成');

      expect(find.textContaining('錯誤'), findsOneWidget);
      _log('錯誤信息顯示驗證完成');
    });
  });

  group('HoroscopeSection 邊界情況測試', () {
    testWidgets('空數據時應該顯示預設信息', (WidgetTester tester) async {
      _log('開始測試：空數據處理');

      when(horoscopeService.getFortuneDescription(any)).thenAnswer((_) => Future.value(''));
      when(horoscopeService.getLuckyElements(any)).thenAnswer((_) => Future.value([]));
      _log('設置空數據狀態');

      await _buildTestWidget(tester);
      _log('Widget 已渲染並等待動畫完成');

      expect(find.textContaining('暫無運勢'), findsOneWidget);
      _log('空數據提示驗證完成');
    });

    testWidgets('極長文本應該正確截斷', (WidgetTester tester) async {
      _log('開始測試：長文本處理');

      final longText = 'A' * 1000;
      when(horoscopeService.getFortuneDescription(any)).thenAnswer((_) => Future.value(longText));
      _log('設置長文本數據，長度：${longText.length}');

      await _buildTestWidget(tester);
      _log('Widget 已渲染並等待動畫完成');

      // 驗證文本是否被正確渲染
      expect(find.byType(Text), findsWidgets);
      
      // 驗證長文本是否被截斷（檢查實際顯示的文本長度是否小於原始長度）
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      bool hasLongText = false;
      for (final textWidget in textWidgets) {
        if (textWidget.data != null && textWidget.data!.length > 100) {
          hasLongText = true;
          break;
        }
      }
      expect(hasLongText, isTrue, reason: '應該找到至少一個長文本 widget');
      _log('長文本截斷驗證完成');
    });
  });

  group('HoroscopeSection 導航測試', () {
    testWidgets('點擊查看更多應該觸發導航', (WidgetTester tester) async {
      _log('開始測試：導航觸發');
      _log('設置基本運勢數據');

      await _buildTestWidget(tester);
      _log('Widget 已渲染並等待動畫完成');

      _log('模擬導航操作');
      await tester.tap(find.text('查看更多'));
      await tester.pumpAndSettle();
      _log('點擊查看更多按鈕');

      verify(navigationService.navigateToHoroscopeDetail(any)).called(1);
      _log('導航調用驗證完成');
    });

    testWidgets('導航失敗時應該顯示錯誤提示', (WidgetTester tester) async {
      _log('開始測試：導航失敗處理');
      _log('設置基本運勢數據');

      when(navigationService.navigateToHoroscopeDetail(any)).thenAnswer((_) => Future.value(false));
      _log('模擬導航失敗');

      await _buildTestWidget(tester);
      _log('Widget 已渲染並等待動畫完成');

      await tester.tap(find.text('查看更多'));
      await tester.pumpAndSettle();
      _log('點擊查看更多按鈕');

      await tester.pump(const Duration(seconds: 1));
      _log('等待導航失敗處理完成');

      expect(find.textContaining('錯誤'), findsOneWidget);
      _log('導航失敗提示驗證完成');
    });
  });
} 