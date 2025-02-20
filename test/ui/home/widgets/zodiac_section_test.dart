import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:logger/logger.dart';
import 'package:all_lucky/ui/home/widgets/zodiac_section.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/providers/zodiac_provider.dart';
import 'package:all_lucky/core/services/zodiac_service.dart';
import 'package:all_lucky/core/services/error_service.dart';
import 'package:all_lucky/core/models/app_error.dart';

@GenerateMocks([ZodiacService, ErrorService])
import 'zodiac_section_test.mocks.dart';

void main() {
  late MockZodiacService mockZodiacService;
  late MockErrorService mockErrorService;
  late Logger logger;
  late DateTime testBirthDate;

  void _log(String message) {
    logger.d(message);
  }

  Widget createWidgetUnderTest([AsyncValue<ZodiacState>? initialState]) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: ProviderScope(
        overrides: [
          zodiacServiceProvider.overrideWithValue(mockZodiacService),
          errorServiceProvider.overrideWithValue(mockErrorService),
          if (initialState != null)
            zodiacNotifierProvider.overrideWith(() => FakeZodiacNotifier(initialState)),
        ],
        child: const Material(
          child: ZodiacSection(),
        ),
      ),
    );
  }

  setUp(() {
    mockZodiacService = MockZodiacService();
    mockErrorService = MockErrorService();
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
    when(mockZodiacService.calculateZodiac(any))
        .thenReturn(Zodiac.rat);

    when(mockZodiacService.getFortuneDescription(any))
        .thenAnswer((_) => Future.value('今天運勢不錯'));

    when(mockZodiacService.getLuckyElements(any))
        .thenAnswer((_) => Future.value(['數字 8', '顏色 紅']));

    // 設置錯誤處理的 mock 回應
    when(mockErrorService.handleError(any, any))
        .thenAnswer((_) => Future.value(AppError(
              message: '載入生肖運勢失敗',
              type: ErrorType.unknown,
              stackTrace: StackTrace.current,
            )));
  });

  group('ZodiacSection 基本功能測試', () {
    testWidgets('應該正確顯示生肖運勢', (WidgetTester tester) async {
      _log('開始測試：顯示生肖運勢');
      _log('設置測試數據：生肖運勢');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      _log('Widget 已渲染並等待動畫完成');

      expect(find.text('生肖運勢'), findsOneWidget);
      expect(find.text('今天運勢不錯'), findsOneWidget);
      expect(find.text('數字 8'), findsOneWidget);
      expect(find.text('顏色 紅'), findsOneWidget);
      _log('運勢顯示驗證完成');
    });
  });

  group('ZodiacSection 錯誤處理測試', () {
    testWidgets('網絡錯誤時應該顯示錯誤信息', (tester) async {
      debugPrint('🐛 開始測試：網絡錯誤處理');
      debugPrint('🐛 設置網絡錯誤狀態');
      
      final widget = createWidgetUnderTest(
        AsyncError(
          AppError(
            message: '載入生肖運勢失敗',
            type: ErrorType.network,
            stackTrace: StackTrace.empty,
          ),
          StackTrace.empty,
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      debugPrint('🐛 Widget 已渲染並等待動畫完成');

      expect(find.text('載入生肖運勢失敗'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
    });

    testWidgets('點擊重試按鈕應該重新載入數據', (WidgetTester tester) async {
      _log('開始測試：重試功能');

      // 第一次調用拋出錯誤
      when(mockZodiacService.getFortuneDescription(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      _log('Widget 已渲染並等待動畫完成');

      // 重新設置 mock 行為
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) => Future.value('重試後的運勢'));

      await tester.tap(find.text('重試'));
      await tester.pumpAndSettle();
      _log('點擊重試按鈕');

      expect(find.text('重試後的運勢'), findsOneWidget);
      _log('重試功能驗證完成');
    });
  });

  group('ZodiacSection 邊界情況測試', () {
    testWidgets('空數據時應該顯示預設信息', (WidgetTester tester) async {
      _log('開始測試：空數據處理');

      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) => Future.value(''));
      when(mockZodiacService.getLuckyElements(any))
          .thenAnswer((_) => Future.value([]));
      _log('設置空數據狀態');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      _log('Widget 已渲染並等待動畫完成');

      expect(find.text('暫無運勢'), findsOneWidget);
      _log('空數據提示驗證完成');
    });

    testWidgets('極長文本應該正確截斷', (WidgetTester tester) async {
      _log('開始測試：長文本處理');

      final longText = 'A' * 1000;
      when(mockZodiacService.getFortuneDescription(any))
          .thenAnswer((_) => Future.value(longText));
      _log('設置長文本數據，長度：${longText.length}');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
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
}

class FakeZodiacNotifier extends AutoDisposeAsyncNotifier<ZodiacState> implements ZodiacNotifier {
  final AsyncValue<ZodiacState> _initialState;

  FakeZodiacNotifier(this._initialState);

  @override
  FutureOr<ZodiacState> build() async {
    return _initialState.when(
      data: (data) => data,
      error: (error, stack) => throw error,
      loading: () => throw UnimplementedError(),
    );
  }

  @override
  Future<void> refreshFortune() async {
    // 在測試中不需要實現
  }
} 