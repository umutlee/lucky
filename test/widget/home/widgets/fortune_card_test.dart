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
  final testDelay = Duration(seconds: 1);

  setUp(() {
    mockFortuneService = MockFortuneService();

    // 設置默認的 mock 行為，添加延遲
    when(mockFortuneService.getDailyFortune(testDate)).thenAnswer((_) async {
      await Future.delayed(testDelay);
      return Fortune(
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

    when(mockFortuneService.getStudyFortune(testDate)).thenAnswer((_) async {
      await Future.delayed(testDelay);
      return Fortune(
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
      );
    });
  });

  group('運勢卡片測試', () {
    testWidgets('基本渲染測試', (tester) async {
      // 構建測試 Widget
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

      // 等待異步操作完成
      await tester.pumpAndSettle();

      // 驗證基本元素存在
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.text('88分'), findsOneWidget);
      expect(find.text('學業運勢'), findsOneWidget);
      expect(find.text('事業運勢'), findsOneWidget);
      expect(find.text('感情運勢'), findsOneWidget);
    });

    testWidgets('運勢分數顯示測試', (tester) async {
      // 準備測試數據
      when(mockFortuneService.getDailyFortune(testDate)).thenAnswer((_) async {
        await Future.delayed(testDelay);
        return Fortune(
          id: '1',
          title: '今日運勢',
          description: '運勢極佳',
          overallScore: 95,
          date: testDate,
          scores: {
            'study': 96,
            'career': 94,
            'love': 95,
          },
          advice: ['大展宏圖', '把握良機'],
          luckyColors: ['紅色'],
          luckyNumbers: ['8'],
          luckyDirections: ['南'],
          type: FortuneType.daily,
        );
      });

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

      // 等待異步操作完成
      await tester.pumpAndSettle();

      // 驗證分數顯示
      expect(find.text('95分'), findsOneWidget);
      expect(find.text('大吉'), findsOneWidget);
      expect(find.text('96'), findsOneWidget); // 學業分數
      expect(find.text('94'), findsOneWidget); // 事業分數
      expect(find.text('95'), findsOneWidget); // 感情分數
    });

    testWidgets('運勢類型切換測試', (tester) async {
      // 準備測試數據
      when(mockFortuneService.getDailyFortune(testDate)).thenAnswer((_) async {
        await Future.delayed(testDelay);
        return Fortune(
          id: '1',
          title: '今日運勢',
          description: '運勢平平',
          overallScore: 70,
          date: testDate,
          scores: {
            'study': 70,
            'career': 70,
            'love': 70,
          },
          advice: ['保持穩定'],
          luckyColors: ['藍色'],
          luckyNumbers: ['7'],
          luckyDirections: ['西'],
          type: FortuneType.daily,
        );
      });

      when(mockFortuneService.getStudyFortune(testDate)).thenAnswer((_) async {
        await Future.delayed(testDelay);
        return Fortune(
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
        );
      });

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

      // 等待異步操作完成
      await tester.pumpAndSettle();

      // 點擊學業運勢
      await tester.tap(find.text('學業運勢'));
      await tester.pumpAndSettle();

      // 驗證學業運勢詳情顯示
      expect(find.text('學習效率高'), findsOneWidget);
      expect(find.text('適合考試'), findsOneWidget);
    });

    testWidgets('點擊跳轉測試', (tester) async {
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

      // 驗證加載指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待異步操作完成
      await tester.pumpAndSettle();

      // 點擊卡片
      await tester.tap(find.byType(FortuneCard));
      await tester.pumpAndSettle();

      // 驗證點擊回調被調用
      expect(onTapCalled, isTrue);
    });

    testWidgets('錯誤狀態測試', (tester) async {
      // 模擬錯誤情況
      when(mockFortuneService.getDailyFortune(testDate)).thenAnswer((_) async {
        await Future.delayed(testDelay);
        throw Exception('測試錯誤');
      });

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

      // 等待異步操作完成
      await tester.pumpAndSettle();

      // 驗證錯誤信息顯示
      expect(find.text('無法加載運勢數據'), findsOneWidget);
      expect(find.text('請稍後重試'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}