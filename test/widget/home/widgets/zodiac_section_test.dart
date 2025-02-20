import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:logger/logger.dart';
import 'package:all_lucky/core/providers/zodiac_provider.dart';
import 'package:all_lucky/core/services/zodiac_service.dart';
import 'package:all_lucky/core/services/error_service.dart';
import 'package:all_lucky/ui/screens/home/widgets/zodiac_section.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/app_error.dart';

@GenerateMocks([ZodiacService, ErrorService])
import 'zodiac_section_test.mocks.dart';

class MockZodiacNotifier extends ZodiacNotifier with Mock {
  AsyncValue<ZodiacState> _state = AsyncData(ZodiacState.initial());
  
  @override
  AsyncValue<ZodiacState> get state => _state;
  
  set state(AsyncValue<ZodiacState> newState) {
    _state = newState;
  }

  @override
  Future<void> refreshFortune() async {
    return;
  }
}

void main() {
  late MockZodiacNotifier mockZodiacNotifier;
  late Logger logger;

  void _log(String message) {
    logger.d(message);
  }

  setUp(() {
    mockZodiacNotifier = MockZodiacNotifier();
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
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: ProviderScope(
        overrides: [
          zodiacNotifierProvider.overrideWith(() => mockZodiacNotifier),
        ],
        child: const Material(
          child: ZodiacSection(),
        ),
      ),
    );
  }

  testWidgets('顯示生肖運勢 - 載入中狀態', (tester) async {
    mockZodiacNotifier.state = const AsyncLoading();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('顯示生肖運勢 - 錯誤狀態', (tester) async {
    mockZodiacNotifier.state = AsyncError(
      '載入生肖運勢失敗',
      StackTrace.empty,
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('載入生肖運勢失敗'), findsOneWidget);
    expect(find.text('重試'), findsOneWidget);

    // 測試重試按鈕
    await tester.tap(find.text('重試'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    
    verify(mockZodiacNotifier.refreshFortune()).called(1);
  });

  testWidgets('顯示生肖運勢 - 無運勢狀態', (tester) async {
    final mockState = ZodiacState(
      userZodiac: Zodiac.rat,
      fortuneDescription: '',
      luckyElements: const [],
      hasError: false,
      errorMessage: null,
    );
    
    mockZodiacNotifier.state = AsyncData(mockState);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('生肖運勢'), findsOneWidget);
    expect(find.text('暫無運勢'), findsOneWidget);
  });

  testWidgets('顯示生肖運勢 - 有運勢狀態', (tester) async {
    final mockState = ZodiacState(
      userZodiac: Zodiac.rat,
      fortuneDescription: '今天運勢不錯',
      luckyElements: const ['紅色', '7', '東'],
      hasError: false,
      errorMessage: null,
    );
    
    mockZodiacNotifier.state = AsyncData(mockState);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('生肖運勢'), findsOneWidget);
    expect(find.text('今天運勢不錯'), findsOneWidget);
    expect(find.text('紅色'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('東'), findsOneWidget);
  });
}