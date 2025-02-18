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
    when(mockFortuneService.getDailyFortune(testDate))
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
      final fortune = Fortune(
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
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: fortune,
            ),
          ),
        ),
      );

      // 驗證基本元素
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('88分'), findsOneWidget);
      expect(find.text('大吉'), findsOneWidget);
      expect(find.text('今日運勢不錯'), findsOneWidget);
    });

    testWidgets('點擊測試', (tester) async {
      bool onTapCalled = false;
      final fortune = Fortune(
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
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: fortune,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FortuneCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('詳細信息展示測試', (tester) async {
      final fortune = Fortune(
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
        advice: ['把握機會', '保持樂觀'],
        luckyColors: ['紅色', '金色'],
        luckyNumbers: ['6', '8'],
        luckyDirections: ['東', '南'],
        type: FortuneType.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: fortune,
              isEnlarged: true,
            ),
          ),
        ),
      );

      // 驗證詳細信息
      expect(find.text('運勢分析'), findsOneWidget);
      expect(find.text('• 把握機會'), findsOneWidget);
      expect(find.text('• 保持樂觀'), findsOneWidget);
      expect(find.text('幸運色'), findsOneWidget);
      expect(find.text('紅色、金色'), findsOneWidget);
      expect(find.text('幸運數字'), findsOneWidget);
      expect(find.text('6、8'), findsOneWidget);
      expect(find.text('幸運方位'), findsOneWidget);
      expect(find.text('東、南'), findsOneWidget);
    });

    testWidgets('運勢等級顯示測試', (tester) async {
      final fortune = Fortune(
        id: '1',
        title: '今日運勢',
        description: '運勢極佳',
        overallScore: 95,
        date: testDate,
        scores: {
          'study': 95,
          'career': 95,
          'love': 95,
        },
        advice: ['大展宏圖'],
        luckyColors: ['紅色'],
        luckyNumbers: ['8'],
        luckyDirections: ['南'],
        type: FortuneType.daily,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: fortune,
            ),
          ),
        ),
      );

      expect(find.text('95分'), findsOneWidget);
      expect(find.text('大吉'), findsOneWidget);
    });
  });
}