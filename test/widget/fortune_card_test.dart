import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/ui/widgets/fortune_card.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/utils/fortune_utils.dart';

void main() {
  late Fortune testFortune;
  final testDate = DateTime(2024, 3, 15);

  setUp(() {
    testFortune = Fortune(
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
    );
  });

  Widget buildTestWidget({
    Fortune? fortune,
    VoidCallback? onTap,
    bool isLoading = false,
    String? errorMessage,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FortuneCard(
          fortune: fortune ?? testFortune,
          onTap: onTap,
          isLoading: isLoading,
          errorMessage: errorMessage,
        ),
      ),
    );
  }

  group('FortuneCard 基本渲染測試', () {
    testWidgets('應該正確顯示基本信息', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 驗證標題和描述
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('今日運勢不錯，適合嘗試新事物'), findsOneWidget);

      // 驗證分數和運勢等級
      expect(find.text('88分'), findsOneWidget);
      expect(find.text('大吉'), findsOneWidget);
    });

    testWidgets('應該正確顯示詳細運勢信息', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 驗證各項運勢分數
      expect(find.text('學業: 85分'), findsOneWidget);
      expect(find.text('事業: 90分'), findsOneWidget);
      expect(find.text('感情: 82分'), findsOneWidget);

      // 驗證建議
      expect(find.text('把握機會'), findsOneWidget);
      expect(find.text('保持樂觀'), findsOneWidget);

      // 驗證吉利物
      expect(find.text('紅色'), findsOneWidget);
      expect(find.text('金色'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('東'), findsOneWidget);
      expect(find.text('南'), findsOneWidget);
    });

    testWidgets('應該正確顯示日期格式', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('2024年3月15日'), findsOneWidget);
    });
  });

  group('FortuneCard 交互測試', () {
    testWidgets('點擊卡片應該觸發回調', (tester) async {
      bool onTapCalled = false;
      await tester.pumpWidget(buildTestWidget(
        onTap: () => onTapCalled = true,
      ));

      await tester.tap(find.byType(FortuneCard));
      await tester.pumpAndSettle();

      expect(onTapCalled, isTrue);
    });

    testWidgets('載入狀態應該顯示進度指示器', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        isLoading: true,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('載入中...'), findsOneWidget);
    });

    testWidgets('錯誤狀態應該顯示錯誤信息', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        errorMessage: '無法載入運勢',
      ));

      expect(find.text('無法載入運勢'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('FortuneCard 邊界情況測試', () {
    testWidgets('極低分數應該顯示為凶', (tester) async {
      final lowScoreFortune = testFortune.copyWith(overallScore: 20);
      await tester.pumpWidget(buildTestWidget(
        fortune: lowScoreFortune,
      ));

      expect(find.text('凶'), findsOneWidget);
    });

    testWidgets('極高分數應該顯示為大吉', (tester) async {
      final highScoreFortune = testFortune.copyWith(overallScore: 95);
      await tester.pumpWidget(buildTestWidget(
        fortune: highScoreFortune,
      ));

      expect(find.text('大吉'), findsOneWidget);
    });

    testWidgets('空建議列表應該顯示預設信息', (tester) async {
      final noAdviceFortune = testFortune.copyWith(advice: []);
      await tester.pumpWidget(buildTestWidget(
        fortune: noAdviceFortune,
      ));

      expect(find.text('暫無建議'), findsOneWidget);
    });

    testWidgets('極長描述文本應該正確截斷', (tester) async {
      final longDescriptionFortune = testFortune.copyWith(
        description: 'a' * 1000,
      );
      await tester.pumpWidget(buildTestWidget(
        fortune: longDescriptionFortune,
      ));

      expect(find.byType(Text), findsWidgets);
    });
  });

  group('FortuneCard 性能測試', () {
    testWidgets('多次重建不應該影響性能', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 重建 widget 多次
      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
      }

      // 驗證基本信息仍然正確顯示
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('88分'), findsOneWidget);
    });

    testWidgets('快速點擊應該正常響應', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(buildTestWidget(
        onTap: () => tapCount++,
      ));

      // 快速點擊多次
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(FortuneCard));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();
      expect(tapCount, 5);
    });
  });
} 