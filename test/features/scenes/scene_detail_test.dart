import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/scene/scene_detail_screen.dart';
import 'package:all_lucky/core/services/scene_service.dart';
import 'package:all_lucky/core/services/fortune_service.dart';
import 'package:all_lucky/core/models/scene.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SceneService, FortuneService])
void main() {
  late MockSceneService mockSceneService;
  late MockFortuneService mockFortuneService;
  final testScene = Scene(
    id: '1',
    title: '考試運勢',
    description: '分析考試時機',
    icon: Icons.school,
    type: SceneType.study,
  );

  setUp(() {
    mockSceneService = MockSceneService();
    mockFortuneService = MockFortuneService();
  });

  group('場景詳情頁面測試', () {
    testWidgets('載入狀態測試', (tester) async {
      when(mockSceneService.getSceneDetail(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => testScene,
        ),
      );

      when(mockFortuneService.getStudyFortune(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => Fortune(
            id: '1',
            title: '考試運勢',
            description: '今日適合考試',
            overallScore: 85,
            date: DateTime.now(),
            scores: {
              'study': 85,
              'focus': 80,
              'memory': 90,
            },
            advice: ['記憶力好', '適合考試'],
            luckyColors: ['黃色'],
            luckyNumbers: ['3'],
            luckyDirections: ['東'],
            type: FortuneType.study,
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
          ],
          child: MaterialApp(
            home: SceneDetailScreen(sceneId: '1'),
          ),
        ),
      );

      // 驗證載入指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待載入完成
      await tester.pumpAndSettle();

      // 驗證場景標題
      expect(find.text('考試運勢'), findsOneWidget);
      expect(find.text('今日適合考試'), findsOneWidget);
    });

    testWidgets('運勢分數顯示測試', (tester) async {
      when(mockSceneService.getSceneDetail(any)).thenAnswer(
        (_) => Future.value(testScene),
      );

      when(mockFortuneService.getStudyFortune(any)).thenAnswer(
        (_) => Future.value(Fortune(
          id: '1',
          title: '考試運勢',
          description: '今日適合考試',
          overallScore: 95,
          date: DateTime.now(),
          scores: {
            'study': 95,
            'focus': 90,
            'memory': 100,
          },
          advice: ['記憶力極佳', '最佳考試時機'],
          luckyColors: ['黃色'],
          luckyNumbers: ['3'],
          luckyDirections: ['東'],
          type: FortuneType.study,
        )),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
          ],
          child: MaterialApp(
            home: SceneDetailScreen(sceneId: '1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證分數顯示
      expect(find.text('95分'), findsOneWidget);
      expect(find.text('大吉'), findsOneWidget);
      expect(find.text('記憶力極佳'), findsOneWidget);
      expect(find.text('最佳考試時機'), findsOneWidget);
    });

    testWidgets('錯誤處理測試', (tester) async {
      when(mockSceneService.getSceneDetail(any)).thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
          ],
          child: MaterialApp(
            home: SceneDetailScreen(sceneId: '1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證錯誤提示
      expect(find.text('載入場景詳情失敗'), findsOneWidget);
      expect(find.text('請稍後重試'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('重試功能測試', (tester) async {
      // 第一次調用拋出錯誤
      when(mockSceneService.getSceneDetail(any))
          .thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
          ],
          child: MaterialApp(
            home: SceneDetailScreen(sceneId: '1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 重新設置 mock 行為
      when(mockSceneService.getSceneDetail(any))
          .thenAnswer((_) => Future.value(testScene));

      // 點擊重試按鈕
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // 驗證重新載入後的內容
      expect(find.text('考試運勢'), findsOneWidget);
    });

    testWidgets('分享功能測試', (tester) async {
      when(mockSceneService.getSceneDetail(any))
          .thenAnswer((_) => Future.value(testScene));

      when(mockFortuneService.getStudyFortune(any)).thenAnswer(
        (_) => Future.value(Fortune(
          id: '1',
          title: '考試運勢',
          description: '今日適合考試',
          overallScore: 85,
          date: DateTime.now(),
          scores: {
            'study': 85,
            'focus': 80,
            'memory': 90,
          },
          advice: ['記憶力好', '適合考試'],
          luckyColors: ['黃色'],
          luckyNumbers: ['3'],
          luckyDirections: ['東'],
          type: FortuneType.study,
        )),
      );

      bool onShareCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
            fortuneServiceProvider.overrideWithValue(mockFortuneService),
          ],
          child: MaterialApp(
            home: SceneDetailScreen(
              sceneId: '1',
              onShare: () {
                onShareCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 點擊分享按鈕
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      // 驗證分享回調
      expect(onShareCalled, isTrue);
    });
  });
} 