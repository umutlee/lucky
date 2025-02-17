import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/scene/scene_selection_screen.dart';
import 'package:all_lucky/core/services/scene_service.dart';
import 'package:all_lucky/core/models/scene.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SceneService])
void main() {
  late MockSceneService mockSceneService;

  setUp(() {
    mockSceneService = MockSceneService();
  });

  group('場景選擇頁面測試', () {
    testWidgets('載入狀態測試', (tester) async {
      when(mockSceneService.getScenes()).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: SceneSelectionScreen(),
          ),
        ),
      );

      // 驗證載入指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 等待載入完成
      await tester.pumpAndSettle();

      // 驗證空狀態提示
      expect(find.text('暫無可用場景'), findsOneWidget);
    });

    testWidgets('場景列表測試', (tester) async {
      final testScenes = [
        Scene(
          id: '1',
          title: '考試運勢',
          description: '分析考試時機',
          icon: Icons.school,
          type: SceneType.study,
        ),
        Scene(
          id: '2',
          title: '戀愛運勢',
          description: '分析桃花運勢',
          icon: Icons.favorite,
          type: SceneType.love,
        ),
      ];

      when(mockSceneService.getScenes()).thenAnswer(
        (_) => Future.value(testScenes),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: SceneSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證場景標題
      expect(find.text('考試運勢'), findsOneWidget);
      expect(find.text('戀愛運勢'), findsOneWidget);

      // 驗證場景描述
      expect(find.text('分析考試時機'), findsOneWidget);
      expect(find.text('分析桃花運勢'), findsOneWidget);
    });

    testWidgets('錯誤處理測試', (tester) async {
      when(mockSceneService.getScenes()).thenThrow(Exception('測試錯誤'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: SceneSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證錯誤提示
      expect(find.text('載入場景失敗'), findsOneWidget);
      expect(find.text('請稍後重試'), findsOneWidget);

      // 驗證重試按鈕
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('下拉刷新測試', (tester) async {
      final testScenes = [
        Scene(
          id: '1',
          title: '考試運勢',
          description: '分析考試時機',
          icon: Icons.school,
          type: SceneType.study,
        ),
      ];

      when(mockSceneService.getScenes()).thenAnswer(
        (_) => Future.value(testScenes),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: const MaterialApp(
            home: SceneSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 執行下拉刷新
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // 驗證是否調用了刷新方法
      verify(mockSceneService.getScenes()).called(2);
    });

    testWidgets('場景點擊測試', (tester) async {
      final testScenes = [
        Scene(
          id: '1',
          title: '考試運勢',
          description: '分析考試時機',
          icon: Icons.school,
          type: SceneType.study,
        ),
      ];

      when(mockSceneService.getScenes()).thenAnswer(
        (_) => Future.value(testScenes),
      );

      bool onTapCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: MaterialApp(
            home: SceneSelectionScreen(
              onSceneSelected: (scene) {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 點擊場景卡片
      await tester.tap(find.text('考試運勢'));
      await tester.pumpAndSettle();

      // 驗證點擊回調
      expect(onTapCalled, isTrue);
    });
  });
} 