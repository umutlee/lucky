import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/scene_service.dart';
import 'package:all_lucky/core/services/fortune_score_service.dart';
import 'package:all_lucky/core/services/time_factor_service.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/models/scene.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

@GenerateMocks([FortuneScoreService, TimeFactorService, Logger])
void main() {
  group('SceneService 測試', () {
    late SceneService sceneService;
    late MockFortuneScoreService mockFortuneScoreService;
    late MockTimeFactorService mockTimeFactorService;
    late MockLogger mockLogger;

    setUp(() {
      mockFortuneScoreService = MockFortuneScoreService();
      mockTimeFactorService = MockTimeFactorService();
      mockLogger = MockLogger();
      sceneService = SceneService(
        mockFortuneScoreService,
        mockTimeFactorService,
        mockLogger,
      );
    });

    test('getScenes 返回場景列表', () async {
      final scenes = await sceneService.getScenes();
      
      expect(scenes, isA<List<Scene>>());
      expect(scenes, isNotEmpty);
      expect(scenes.first.id, 'temple');
    });

    test('getSceneById 返回正確的場景', () async {
      final scene = await sceneService.getSceneById('temple');
      
      expect(scene.id, 'temple');
      expect(scene.name, '古寺祈福');
      expect(scene.type, FortuneType.daily);
    });

    test('getSceneById 找不到場景時拋出異常', () async {
      expect(
        () => sceneService.getSceneById('non_existent'),
        throwsException,
      );
    });

    test('unlockScene 解鎖場景', () async {
      await sceneService.unlockScene('mountain');
      final scene = await sceneService.getSceneById('mountain');
      
      expect(scene.isUnlocked, isTrue);
    });

    test('incrementViewCount 增加瀏覽次數', () async {
      final beforeScene = await sceneService.getSceneById('temple');
      final beforeCount = beforeScene.viewCount;
      
      await sceneService.incrementViewCount('temple');
      final afterScene = await sceneService.getSceneById('temple');
      
      expect(afterScene.viewCount, equals(beforeCount + 1));
      expect(afterScene.lastViewedAt, isNotNull);
    });

    test('getRecommendedScenes 返回推薦場景', () async {
      when(() => mockTimeFactorService.calculateTimeScore(
        any(),
        any(),
      )).thenReturn(0.8);

      when(() => mockFortuneScoreService.calculateFortuneScore(
        date: any(named: 'date'),
        type: any(named: 'type'),
      )).thenAnswer((_) async => (
        score: 85,
        factors: {'time': 0.8, 'fortune': 0.9},
        suggestions: ['測試建議'],
      ));

      final recommendedScenes = await sceneService.getRecommendedScenes(
        date: DateTime.now(),
      );

      expect(recommendedScenes, isA<List<Scene>>());
      expect(recommendedScenes.length, lessThanOrEqualTo(3));
      expect(recommendedScenes.first.isUnlocked, isTrue);
    });

    test('緩存機制正常工作', () async {
      // 第一次調用
      final firstCall = await sceneService.getScenes();
      
      // 第二次調用應該使用緩存
      final secondCall = await sceneService.getScenes();
      
      expect(identical(firstCall, secondCall), isTrue);
      
      // 清除緩存後應該重新獲取
      sceneService.dispose();
      final thirdCall = await sceneService.getScenes();
      
      expect(identical(secondCall, thirdCall), isFalse);
    });

    test('分頁加載正常工作', () async {
      // 第一頁
      final firstPage = await sceneService.getScenes();
      expect(firstPage.length, lessThanOrEqualTo(10));
      
      // 第二頁
      final secondPage = await sceneService.getMoreScenes();
      expect(secondPage.length, lessThanOrEqualTo(10));
      
      // 確保沒有重複
      final allSceneIds = [...firstPage, ...secondPage]
          .map((s) => s.id)
          .toSet();
      expect(allSceneIds.length, equals(firstPage.length + secondPage.length));
    });
  });
} 