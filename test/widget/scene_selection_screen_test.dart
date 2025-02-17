import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/ui/screens/scene/scene_selection_screen.dart';
import 'package:all_lucky/core/models/scene.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/services/scene_service.dart';
import 'scene_selection_screen_test.mocks.dart';

@GenerateMocks([SceneService])
void main() {
  group('場景選擇頁面測試', () {
    late MockSceneService mockSceneService;

    setUp(() {
      mockSceneService = MockSceneService();
    });

    testWidgets('載入時顯示載入動畫', (tester) async {
      when(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

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

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('顯示推薦場景', (tester) async {
      final scenes = [
        Scene(
          id: 'scene1',
          name: '晨光祈福',
          description: '在晨光中感受新的一天的祝福',
          imageUrl: 'https://example.com/scene1.jpg',
          imagePath: 'assets/images/scenes/scene1.jpg',
          type: FortuneType.daily,
          baseScore: 80,
          tags: ['晨間', '祈福', '新的開始'],
        ),
        Scene(
          id: 'scene2',
          name: '書房靈感',
          description: '在書房中尋找學習的靈感',
          imageUrl: 'https://example.com/scene2.jpg',
          imagePath: 'assets/images/scenes/scene2.jpg',
          type: FortuneType.study,
          baseScore: 85,
          tags: ['學習', '靈感', '專注'],
        ),
      ];

      when(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).thenAnswer((_) async => scenes);

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

      expect(find.text('晨光祈福'), findsOneWidget);
      expect(find.text('書房靈感'), findsOneWidget);
    });

    testWidgets('顯示錯誤信息並允許重試', (tester) async {
      when(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        throw Exception('測試錯誤');
      });

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

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('載入失敗'), findsOneWidget);
      
      final retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      verify(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).called(2);
    });

    testWidgets('支持下拉刷新', (tester) async {
      final scenes = [
        Scene(
          id: 'scene1',
          name: '晨光祈福',
          description: '在晨光中感受新的一天的祝福',
          imageUrl: 'https://example.com/scene1.jpg',
          imagePath: 'assets/images/scenes/scene1.jpg',
          type: FortuneType.daily,
          baseScore: 80,
          tags: ['晨間', '祈福', '新的開始'],
        ),
      ];

      when(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return scenes;
      });

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
      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 驗證加載場景的調用
      verify(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).called(1);

      // 驗證場景是否顯示
      expect(find.text('晨光祈福'), findsOneWidget);
    });

    testWidgets('支持無限滾動', (tester) async {
      final initialScenes = [
        Scene(
          id: 'scene1',
          name: '晨光祈福',
          description: '在晨光中感受新的一天的祝福',
          imageUrl: 'https://example.com/scene1.jpg',
          imagePath: 'assets/images/scenes/scene1.jpg',
          type: FortuneType.daily,
          baseScore: 80,
          tags: ['晨間', '祈福', '新的開始'],
        ),
      ];

      final moreScenes = [
        Scene(
          id: 'scene2',
          name: '書房靈感',
          description: '在書房中尋找學習的靈感',
          imageUrl: 'https://example.com/scene2.jpg',
          imagePath: 'assets/images/scenes/scene2.jpg',
          type: FortuneType.study,
          baseScore: 85,
          tags: ['學習', '靈感', '專注'],
        ),
      ];

      when(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return initialScenes;
      });

      when(mockSceneService.getMoreRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
        lastScene: initialScenes[0],
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return moreScenes;
      });

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

      // 滾動到底部
      final scrollView = find.byType(CustomScrollView);
      await tester.drag(scrollView, const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 等待加載更多場景
      await tester.pump(const Duration(milliseconds: 500));

      // 驗證加載更多場景的調用
      verify(mockSceneService.getMoreRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
        lastScene: initialScenes[0],
      )).called(1);

      // 驗證新場景是否顯示
      expect(find.text('書房靈感'), findsOneWidget);
    });

    testWidgets('點擊場景卡片導航到詳情頁面', (tester) async {
      final scene = Scene(
        id: 'scene1',
        name: '晨光祈福',
        description: '在晨光中感受新的一天的祝福',
        imageUrl: 'https://example.com/scene1.jpg',
        imagePath: 'assets/images/scenes/scene1.jpg',
        type: FortuneType.daily,
        baseScore: 80,
        tags: ['晨間', '祈福', '新的開始'],
      );

      when(mockSceneService.getRecommendedScenes(
        date: anyNamed('date'),
        userPreferences: anyNamed('userPreferences'),
      )).thenAnswer((_) async => [scene]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sceneServiceProvider.overrideWithValue(mockSceneService),
          ],
          child: MaterialApp(
            home: const SceneSelectionScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/scene/detail') {
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: Center(
                      child: Text('場景詳情頁面'),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('晨光祈福'));
      await tester.pumpAndSettle();

      expect(find.text('場景詳情頁面'), findsOneWidget);
    });
  });
} 