import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene.dart';
import '../models/fortune_type.dart';
import '../utils/logger.dart';
import 'fortune_score_service.dart';
import 'time_factor_service.dart';

final sceneServiceProvider = Provider<SceneService>((ref) {
  final fortuneScoreService = ref.watch(fortuneScoreServiceProvider);
  final timeFactorService = ref.watch(timeFactorServiceProvider);
  final logger = Logger('SceneService');
  return SceneService(
    fortuneScoreService,
    timeFactorService,
    logger,
  );
});

class SceneService {
  final List<Scene> _scenes = [
    Scene(
      id: 'temple',
      name: '古寺祈福',
      description: '在寧靜的古寺中尋求智慧與指引',
      imagePath: 'assets/images/scenes/temple.jpg',
      type: FortuneType.daily,
      baseScore: 80,
      isUnlocked: true,
    ),
    Scene(
      id: 'garden',
      name: '禪意花園',
      description: '在幽靜的花園中感受自然的啟示',
      imagePath: 'assets/images/scenes/garden.jpg',
      type: FortuneType.love,
      baseScore: 75,
      isUnlocked: true,
    ),
    Scene(
      id: 'mountain',
      name: '靈山秘境',
      description: '在雲霧繚繞的山巔尋找生命的答案',
      imagePath: 'assets/images/scenes/mountain.jpg',
      type: FortuneType.career,
      baseScore: 85,
      isUnlocked: false,
      unlockCondition: '完成3次占卜解鎖',
    ),
    Scene(
      id: 'lake',
      name: '月光湖畔',
      description: '在皎潔的月光下聆聽內心的聲音',
      imagePath: 'assets/images/scenes/lake.jpg',
      type: FortuneType.study,
      baseScore: 70,
      isUnlocked: false,
      unlockCondition: '完成5次占卜解鎖',
    ),
  ];

  final FortuneScoreService _fortuneScoreService;
  final TimeFactorService _timeFactorService;
  final Logger _logger;

  // 場景緩存
  List<Scene>? _cachedScenes;
  DateTime? _lastCacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  SceneService(
    this._fortuneScoreService,
    this._timeFactorService,
    this._logger,
  );

  Future<List<Scene>> getScenes() async {
    try {
      if (_isCacheValid()) {
        _logger.info('使用緩存的場景數據');
        return _cachedScenes!;
      }

      await Future.delayed(const Duration(seconds: 1));
      _cachedScenes = List.from(_scenes);
      _lastCacheTime = DateTime.now();
      _logger.info('更新場景緩存');
      return _cachedScenes!;
    } catch (e, stack) {
      _logger.error('獲取場景列表失敗', e, stack);
      rethrow;
    }
  }

  Future<Scene> getSceneById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final scene = _scenes.firstWhere(
        (scene) => scene.id == id,
        orElse: () => throw Exception('找不到場景：$id'),
      );
      _logger.info('獲取場景：${scene.name}');
      return scene;
    } catch (e, stack) {
      _logger.error('獲取場景失敗：$id', e, stack);
      rethrow;
    }
  }

  Future<void> unlockScene(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _scenes.indexWhere((scene) => scene.id == id);
      if (index == -1) {
        throw Exception('找不到場景：$id');
      }
      
      _scenes[index] = _scenes[index].copyWith(isUnlocked: true);
      _invalidateCache();
      _logger.info('解鎖場景：${_scenes[index].name}');
    } catch (e, stack) {
      _logger.error('解鎖場景失敗：$id', e, stack);
      rethrow;
    }
  }

  Future<void> incrementViewCount(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _scenes.indexWhere((scene) => scene.id == id);
      if (index == -1) {
        throw Exception('找不到場景：$id');
      }
      
      _scenes[index] = _scenes[index].copyWith(
        viewCount: _scenes[index].viewCount + 1,
        lastViewedAt: DateTime.now(),
      );
      _invalidateCache();
      _logger.info('增加場景瀏覽次數：${_scenes[index].name}');
    } catch (e, stack) {
      _logger.error('增加場景瀏覽次數失敗：$id', e, stack);
      rethrow;
    }
  }

  /// 獲取推薦場景
  Future<List<Scene>> getRecommendedScenes({
    required DateTime date,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final allScenes = await getScenes();
      final recommendations = <Scene>[];
      final scores = <String, double>{};
      
      // 計算所有場景的分數
      for (final scene in allScenes) {
        if (!scene.isUnlocked) continue;
        
        final score = await _calculateSceneScore(
          scene,
          date,
          userPreferences,
        );
        scores[scene.id] = score;
        
        if (score >= 0.7) {
          recommendations.add(scene);
        }
      }
      
      // 根據分數排序
      recommendations.sort((a, b) {
        final scoreA = scores[a.id] ?? 0.0;
        final scoreB = scores[b.id] ?? 0.0;
        return scoreB.compareTo(scoreA);
      });
      
      // 返回前3個最推薦的場景
      final result = recommendations.take(3).toList();
      _logger.info('獲取推薦場景：${result.map((s) => s.name).join(', ')}');
      return result;
    } catch (e, stack) {
      _logger.error('獲取推薦場景失敗', e, stack);
      return [];
    }
  }

  /// 計算場景分數
  Future<double> _calculateSceneScore(
    Scene scene,
    DateTime date,
    Map<String, dynamic>? userPreferences,
  ) async {
    try {
      // 基礎分數權重
      const weights = {
        'timeScore': 0.3,     // 時間因素
        'seasonScore': 0.2,   // 季節因素
        'userScore': 0.3,     // 用戶偏好
        'fortuneScore': 0.2,  // 運勢分數
      };
      
      // 計算時間分數
      final timeScore = _timeFactorService.calculateTimeScore(
        date,
        scene.type,
      );
      
      // 計算季節分數
      final seasonScore = _calculateSeasonScore(scene, date);
      
      // 計算用戶偏好分數
      final userScore = _calculateUserPreferenceScore(
        scene,
        userPreferences,
      );
      
      // 計算運勢分數
      final fortuneData = await _fortuneScoreService.calculateFortuneScore(
        date: date,
        type: scene.type,
      );
      final fortuneScore = fortuneData.score / 100;
      
      // 計算加權總分
      final totalScore = 
        timeScore * weights['timeScore']! +
        seasonScore * weights['seasonScore']! +
        userScore * weights['userScore']! +
        fortuneScore * weights['fortuneScore']!;
      
      return totalScore.clamp(0.0, 1.0);
    } catch (e, stack) {
      _logger.error('計算場景分數失敗：${scene.name}', e, stack);
      return 0.5;
    }
  }

  /// 計算季節分數
  double _calculateSeasonScore(Scene scene, DateTime date) {
    try {
      final month = date.month;
      
      // 根據場景類型和月份計算適合度
      return switch (scene.type) {
        FortuneType.study => switch (month) {
          3 || 4 || 5 || 9 || 10 || 11 => 0.9, // 春秋季最適合學習
          6 || 7 || 8 => 0.6,                  // 夏季較難專注
          _ => 0.7,                            // 冬季一般
        },
        FortuneType.travel => switch (month) {
          3 || 4 || 5 || 9 || 10 => 0.9,      // 春秋季最適合旅遊
          6 || 7 || 8 => 0.7,                  // 夏季一般
          _ => 0.6,                            // 冬季較差
        },
        _ => 0.7, // 其他類型場景不受季節影響
      };
    } catch (e) {
      _logger.warning('計算季節分數失敗：${scene.name}', e);
      return 0.7;
    }
  }

  /// 計算用戶偏好分數
  double _calculateUserPreferenceScore(
    Scene scene,
    Map<String, dynamic>? userPreferences,
  ) {
    if (userPreferences == null) return 0.7;
    
    try {
      var score = 0.7; // 基礎分數
      
      // 檢查用戶興趣
      final interests = userPreferences['interests'] as List<String>?;
      if (interests != null && interests.isNotEmpty) {
        if (interests.contains(scene.type.toString())) {
          score += 0.2;
        }
      }
      
      // 檢查歷史記錄
      final history = userPreferences['history'] as Map<String, int>?;
      if (history != null && history.containsKey(scene.id)) {
        final frequency = history[scene.id]!;
        if (frequency > 10) {
          score += 0.1;
        }
      }
      
      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算用戶偏好分數失敗：${scene.name}', e);
      return 0.7;
    }
  }

  /// 檢查緩存是否有效
  bool _isCacheValid() {
    if (_cachedScenes == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheDuration;
  }

  /// 使緩存失效
  void _invalidateCache() {
    _cachedScenes = null;
    _lastCacheTime = null;
    _logger.info('清除場景緩存');
  }

  /// 清理資源
  void dispose() {
    _invalidateCache();
    _logger.info('釋放場景服務資源');
  }
} 