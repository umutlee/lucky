import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/ui/widgets/fortune_card.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

void main() {
  late Fortune testFortune;

  setUp(() {
    testFortune = Fortune(
      id: '1',
      title: '今日運勢',
      description: '今日運勢不錯，適合嘗試新事物',
      overallScore: 88,
      date: DateTime.now(),
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
  });

  group('FortuneCard 基本渲染測試', () {
    testWidgets('應該正確顯示基本信息', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: testFortune,
            ),
          ),
        ),
      );

      // 驗證標題和描述
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('今日運勢不錯，適合嘗試新事物'), findsOneWidget);

      // 驗證分數和運勢等級
      expect(find.text('88分'), findsOneWidget);
      expect(find.text('大吉'), findsOneWidget);
    });

    testWidgets('展開時應該顯示詳細信息', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: testFortune,
              isEnlarged: true,
            ),
          ),
        ),
      );

      // 驗證運勢分析標題
      expect(find.text('運勢分析'), findsOneWidget);

      // 驗證建議列表
      expect(find.text('• 把握機會'), findsOneWidget);
      expect(find.text('• 保持樂觀'), findsOneWidget);

      // 驗證幸運元素
      expect(find.text('幸運色'), findsOneWidget);
      expect(find.text('紅色、金色'), findsOneWidget);
      expect(find.text('幸運數字'), findsOneWidget);
      expect(find.text('6、8'), findsOneWidget);
      expect(find.text('幸運方位'), findsOneWidget);
      expect(find.text('東、南'), findsOneWidget);
    });

    testWidgets('單擊回調應該正確觸發', (tester) async {
      bool onTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: testFortune,
              onTap: () => onTapCalled = true,
            ),
          ),
        ),
      );

      // 測試單擊
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(onTapCalled, isTrue);
    });

    testWidgets('雙擊回調應該正確觸發', (tester) async {
      bool onDoubleTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              fortune: testFortune,
              onDoubleTap: () => onDoubleTapCalled = true,
            ),
          ),
        ),
      );

      // 測試雙擊
      await tester.tap(find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(onDoubleTapCalled, isTrue);
    });

    testWidgets('不同運勢等級應該顯示不同顏色', (tester) async {
      final fortuneGreat = testFortune.copyWith(overallScore: 95); // 大吉
      final fortuneGood = testFortune.copyWith(overallScore: 75);  // 小吉
      final fortuneNormal = testFortune.copyWith(overallScore: 50); // 平
      final fortuneBad = testFortune.copyWith(overallScore: 30);   // 小凶
      final fortuneWorst = testFortune.copyWith(overallScore: 10); // 凶

      // 測試大吉
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(fortune: fortuneGreat),
          ),
        ),
      );
      expect(find.text('大吉'), findsOneWidget);

      // 測試小吉
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(fortune: fortuneGood),
          ),
        ),
      );
      expect(find.text('小吉'), findsOneWidget);

      // 測試平
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(fortune: fortuneNormal),
          ),
        ),
      );
      expect(find.text('平'), findsOneWidget);

      // 測試小凶
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(fortune: fortuneBad),
          ),
        ),
      );
      expect(find.text('小凶'), findsOneWidget);

      // 測試凶
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(fortune: fortuneWorst),
          ),
        ),
      );
      expect(find.text('凶'), findsOneWidget);
    });
  });
} 