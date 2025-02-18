import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/home/widgets/fortune_card.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/fortune_level.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/services/fortune_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FortuneService])
import 'fortune_card_test.mocks.dart';

void main() {
  late MockFortuneService mockFortuneService;
  final testDate = DateTime(2024, 2, 17);

  setUp(() {
    mockFortuneService = MockFortuneService();

    // 設置基本的 mock 回應
    when(mockFortuneService.getDailyFortune(any))
        .thenAnswer((_) async => Fortune(
              id: '1',
              title: '今日運勢',
              description: '今日運勢不錯，適合嘗試新事物',
              overallScore: 88,
              date: testDate,
              scores: {
                'study': 85,
                'career': 90,
                'love': 82,
              },
              advice: ['把握機會', '保持樂觀'],
              luckyColors: ['紅色', '金色'],
              luckyNumbers: ['6', '8'],
              luckyDirections: ['東', '南'],
              type: FortuneType.daily,
            ));

    when(mockFortuneService.getStudyFortune(testDate))
        .thenAnswer((_) async => Fortune(
              id: '2',
              title: '學業運勢',
              description: '學習效率高',
              overallScore: 85,
              date: testDate,
              scores: {
                'study': 85,
                'focus': 80,
                'memory': 90,
              },
              advice: ['適合考試', '記憶力好'],
              luckyColors: ['黃色'],
              luckyNumbers: ['3'],
              luckyDirections: ['東'],
              type: FortuneType.study,
            ));
  });

  group('運勢卡片測試', () {
    testWidgets('基本渲染測試', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            dateProvider.overrideWithValue(testDate),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FortuneCard(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 驗證基本元素
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('今日運勢不錯，適合嘗試新事物'), findsOneWidget);
    });

    testWidgets('點擊測試', (tester) async {
      bool onTapCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            dateProvider.overrideWithValue(testDate),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FortuneCard(
                onTap: () {
                  onTapCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(FortuneCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('錯誤狀態測試', (tester) async {
      when(mockFortuneService.getDailyFortune(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            dateProvider.overrideWithValue(testDate),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FortuneCard(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('無法加載運勢數據'), findsOneWidget);
      expect(find.text('請稍後重試'), findsOneWidget);
    });

    testWidgets('加載狀態測試', (tester) async {
      // 使用 Completer 來控制異步操作
      final completer = Completer<Fortune>();
      when(mockFortuneService.getDailyFortune(any))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
            dateProvider.overrideWithValue(testDate),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FortuneCard(),
            ),
          ),
        ),
      );

      // 驗證加載指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 完成加載
      completer.complete(Fortune(
        id: '1',
        title: '今日運勢',
        description: '今日運勢不錯',
        overallScore: 88,
        date: testDate,
        scores: {
          'study': 85,
          'career': 90,
          'love': 82,
        },
        advice: ['把握機會'],
        luckyColors: ['紅色'],
        luckyNumbers: ['8'],
        luckyDirections: ['東'],
        type: FortuneType.daily,
      ));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // 驗證內容已加載
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('今日運勢不錯'), findsOneWidget);
    });
  });
}