import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene.dart';
import 'logger_service.dart';
import 'fortune_score_service.dart';
import 'time_factor_service.dart';

final sceneServiceProvider = Provider<SceneService>((ref) {
  final logger = ref.watch(loggerServiceProvider);
  final fortuneScoreService = ref.watch(fortuneScoreServiceProvider);
  final timeFactorService = ref.watch(timeFactorServiceProvider);
  return SceneService(logger, fortuneScoreService, timeFactorService);
});

class SceneService {
  final LoggerService _logger;
  final FortuneScoreService _fortuneScoreService;
  final TimeFactorService _timeFactorService;

  // 場景緩存
  List<Scene>? _cachedScenes;
  DateTime? _lastCacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  SceneService(this._logger, this._fortuneScoreService, this._timeFactorService);

  Future<List<Scene>> getScenes() async {
    try {
      // 檢查緩存是否有效
      if (_isCacheValid()) {
        return _cachedScenes!;
      }

      // TODO: 從API獲取場景數據
      // 目前返回擴展的模擬數據
      final scenes = [
        const Scene(
          id: 'study',
          name: '學習運勢',
          description: '考試、學習、升學運勢分析',
          imageAsset: 'assets/images/scenes/study.jpg',
          type: 'study',
          parameters: {
            'difficulty': 'medium',
            'subjects': ['數學', '物理', '化學', '語文'],
            'examTypes': ['期中考試', '期末考試', '入學考試'],
            'studyMethods': ['自習', '小組學習', '線上課程'],
          },
        ),
        const Scene(
          id: 'career',
          name: '職場運勢',
          description: '工作、升遷、創業運勢分析',
          imageAsset: 'assets/images/scenes/career.jpg',
          type: 'career',
          parameters: {
            'industry': 'general',
            'positions': ['技術', '管理', '銷售', '創業'],
            'activities': ['面試', '述職', '談判', '簽約'],
            'skills': ['溝通', '領導', '專業', '創新'],
          },
        ),
        const Scene(
          id: 'love',
          name: '感情運勢',
          description: '戀愛、婚姻、人際關係分析',
          imageAsset: 'assets/images/scenes/love.jpg',
          type: 'love',
          parameters: {
            'status': 'single',
            'relationshipTypes': ['戀愛', '婚姻', '友情'],
            'activities': ['約會', '告白', '求婚', '社交'],
            'places': ['餐廳', '電影院', '公園', '旅遊'],
          },
        ),
        const Scene(
          id: 'wealth',
          name: '財運分析',
          description: '投資、理財、收入運勢分析',
          imageAsset: 'assets/images/scenes/wealth.jpg',
          type: 'wealth',
          parameters: {
            'risk_level': 'medium',
            'investmentTypes': ['股票', '基金', '房地產', '創業'],
            'activities': ['投資', '理財', '談判', '合作'],
            'methods': ['長期投資', '短期理財', '定期儲蓄'],
          },
        ),
        const Scene(
          id: 'health',
          name: '健康運勢',
          description: '身體、心理健康運勢分析',
          imageAsset: 'assets/images/scenes/health.jpg',
          type: 'health',
          parameters: {
            'focus': 'general',
            'aspects': ['身體', '心理', '飲食', '運動'],
            'activities': ['體檢', '運動', '養生', '調理'],
            'methods': ['規律作息', '均衡飲食', '適度運動'],
          },
        ),
        const Scene(
          id: 'travel',
          name: '旅行運勢',
          description: '出行、旅遊、探險運勢分析',
          imageAsset: 'assets/images/scenes/travel.jpg',
          type: 'travel',
          parameters: {
            'duration': 'short',
            'types': ['觀光', '探險', '美食', '文化'],
            'destinations': ['國內', '國外', '近郊', '長途'],
            'activities': ['景點遊覽', '美食探索', '文化體驗'],
          },
        ),
        const Scene(
          id: 'social',
          name: '社交運勢',
          description: '人際關係、社交活動運勢分析',
          imageAsset: 'assets/images/scenes/social.jpg',
          type: 'social',
          parameters: {
            'scope': 'general',
            'types': ['商務社交', '朋友聚會', '家庭聚會'],
            'activities': ['聚會', '談判', '合作', '溝通'],
            'skills': ['表達', '傾聽', '禮儀', '情商'],
          },
        ),
        const Scene(
          id: 'creativity',
          name: '創意運勢',
          description: '藝術創作、設計靈感運勢分析',
          imageAsset: 'assets/images/scenes/creativity.jpg',
          type: 'creativity',
          parameters: {
            'field': 'general',
            'types': ['藝術', '設計', '寫作', '音樂'],
            'activities': ['創作', '展演', '發表', '競賽'],
            'methods': ['靈感激發', '技巧練習', '作品完善'],
          },
        ),
      ];

      // 更新緩存
      _cachedScenes = scenes;
      _lastCacheTime = DateTime.now();

      return scenes;
    } catch (e, stack) {
      _logger.error('獲取場景列表失敗', e, stack);
      return [];
    }
  }

  Future<Scene> getSceneById(String id) async {
    final scenes = await getScenes();
    return scenes.firstWhere((scene) => scene.id == id);
  }

  /// 獲取推薦場景
  Future<List<Scene>> getRecommendedScenes({
    required DateTime date,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final allScenes = await getScenes();
      final recommendations = <Scene>[];
      
      for (final scene in allScenes) {
        final score = await _calculateSceneScore(
          scene,
          date,
          userPreferences,
        );
        
        if (score >= 0.7) {
          recommendations.add(scene);
        }
      }
      
      // 根據分數排序
      recommendations.sort((a, b) {
        final scoreA = _getSceneScore(a, date, userPreferences);
        final scoreB = _getSceneScore(b, date, userPreferences);
        return scoreB.compareTo(scoreA);
      });
      
      // 返回前3個最推薦的場景
      return recommendations.take(3).toList();
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
        FortuneType.values.firstWhere(
          (t) => t.toString() == 'FortuneType.${scene.type}',
          orElse: () => FortuneType.daily,
        ),
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
        type: FortuneType.values.firstWhere(
          (t) => t.toString() == 'FortuneType.${scene.type}',
          orElse: () => FortuneType.daily,
        ),
      );
      final fortuneScore = fortuneData.score / 100;
      
      // 計算加權總分
      final totalScore = 
        timeScore * weights['timeScore']! +
        seasonScore * weights['seasonScore']! +
        userScore * weights['userScore']! +
        fortuneScore * weights['fortuneScore']!;
      
      return totalScore;
    } catch (e, stack) {
      _logger.error('計算場景分數失敗', e, stack);
      return 0.5;
    }
  }

  /// 計算季節分數
  double _calculateSeasonScore(Scene scene, DateTime date) {
    final month = date.month;
    
    // 根據場景類型和月份計算適合度
    switch (scene.type) {
      case 'study':
        return switch (month) {
          3 || 4 || 5 || 9 || 10 || 11 => 0.9, // 春秋季最適合學習
          6 || 7 || 8 => 0.6,                  // 夏季較難專注
          _ => 0.7,                            // 冬季一般
        };
      case 'travel':
        return switch (month) {
          3 || 4 || 5 || 9 || 10 => 0.9,      // 春秋季最適合旅遊
          6 || 7 || 8 => 0.7,                  // 夏季一般
          _ => 0.6,                            // 冬季較差
        };
      default:
        return 0.7; // 其他類型場景不受季節影響
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
        if (interests.contains(scene.type)) {
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
      
      // 確保分數在 0-1 範圍內
      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算用戶偏好分數失敗: $e');
      return 0.7;
    }
  }

  /// 獲取場景分數（用於排序）
  double _getSceneScore(
    Scene scene,
    DateTime date,
    Map<String, dynamic>? userPreferences,
  ) {
    try {
      return _calculateSceneScore(scene, date, userPreferences).then(
        (score) => score,
        onError: (e) => 0.5,
      );
    } catch (e) {
      return 0.5;
    }
  }

  /// 檢查緩存是否有效
  bool _isCacheValid() {
    if (_cachedScenes == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheDuration;
  }
} 