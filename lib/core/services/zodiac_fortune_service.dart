import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../utils/zodiac_image_helper.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/services/api_client.dart';

final zodiacFortuneServiceProvider = Provider<ZodiacFortuneService>(
  (ref) => ZodiacFortuneService(ref.read(apiClientProvider)),
);

class ZodiacFortuneService {
  final ApiClient _apiClient;

  ZodiacFortuneService(this._apiClient);

  // 生肖相性表（基礎分數）
  final Map<String, Map<String, int>> _baseAffinityScores = {
    '鼠': {'龍': 90, '猴': 85, '牛': 60, '虎': 40},
    '牛': {'蛇': 90, '雞': 85, '鼠': 60, '羊': 40},
    '虎': {'馬': 90, '狗': 85, '豬': 60, '猴': 40},
    '兔': {'羊': 90, '豬': 85, '狗': 60, '雞': 40},
    '龍': {'鼠': 90, '猴': 85, '雞': 60, '狗': 40},
    '蛇': {'牛': 90, '雞': 85, '馬': 60, '豬': 40},
    '馬': {'虎': 90, '狗': 85, '羊': 60, '兔': 40},
    '羊': {'兔': 90, '豬': 85, '馬': 60, '牛': 40},
    '猴': {'龍': 90, '鼠': 85, '蛇': 60, '虎': 40},
    '雞': {'牛': 90, '蛇': 85, '龍': 60, '兔': 40},
    '狗': {'虎': 90, '馬': 85, '兔': 60, '龍': 40},
    '豬': {'兔': 90, '羊': 85, '虎': 60, '蛇': 40},
  };

  // 根據運勢類型獲取相關的生肖
  List<String> _getRelatedZodiacs(String fortuneType) {
    switch (fortuneType) {
      case '事業':
        return ['龍', '虎', '牛']; // 代表權威、力量和勤勉
      case '學習':
        return ['兔', '蛇', '猴']; // 代表智慧、耐心和靈活
      case '財運':
        return ['鼠', '龍', '猴']; // 代表機敏、威望和智慧
      case '人際':
        return ['馬', '羊', '豬']; // 代表活潑、溫和和善良
      default:
        return ['龍', '虎', '兔']; // 默認組合
    }
  }

  // 計算生肖相性分數
  Map<String, int> calculateZodiacAffinity(String zodiac, String fortuneType) {
    final baseScores = _baseAffinityScores[zodiac] ?? {};
    final relatedZodiacs = _getRelatedZodiacs(fortuneType);
    
    // 創建完整的相性分數表
    final Map<String, int> affinity = {};
    final allZodiacs = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
    
    for (final targetZodiac in allZodiacs) {
      // 基礎分數
      int score = baseScores[targetZodiac] ?? 70;
      
      // 如果目標生肖在相關生肖列表中，提高分數
      if (relatedZodiacs.contains(targetZodiac)) {
        score = (score * 1.2).round();
      }
      
      // 確保分數在合理範圍內
      score = score.clamp(0, 100);
      affinity[targetZodiac] = score;
    }
    
    return affinity;
  }

  // 根據生肖和運勢類型生成建議
  List<String> generateZodiacRecommendations(String zodiac, String fortuneType, int score) {
    final recommendations = <String>[];
    final relatedZodiacs = _getRelatedZodiacs(fortuneType);
    
    // 基於運勢分數的建議
    if (score >= 80) {
      recommendations.add('今天是屬$zodiac的你大展身手的好時機');
      if (relatedZodiacs.contains(zodiac)) {
        recommendations.add('你的生肖特質特別適合今天的$fortuneType相關活動');
      }
    } else if (score >= 60) {
      recommendations.add('屬$zodiac的你今天保持平常心最重要');
      if (relatedZodiacs.contains(zodiac)) {
        recommendations.add('可以嘗試發揮你的生肖優勢來改善運勢');
      }
    } else {
      recommendations.add('屬$zodiac的你今天需要多加小心');
      final bestMatch = _baseAffinityScores[zodiac]?.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      if (bestMatch != null) {
        recommendations.add('建議可以尋求屬$bestMatch的朋友協助');
      }
    }
    
    return recommendations;
  }

  // 增強運勢對象
  Fortune enhanceFortuneWithZodiac(Fortune fortune, String userZodiac) {
    // 計算生肖相性
    final zodiacAffinity = calculateZodiacAffinity(userZodiac, fortune.type);
    
    // 生成生肖相關建議
    final zodiacRecommendations = generateZodiacRecommendations(
      userZodiac,
      fortune.type,
      fortune.score,
    );
    
    // 合併原有建議和生肖建議
    final allRecommendations = [
      ...fortune.recommendations,
      ...zodiacRecommendations,
    ];
    
    // 返回增強後的運勢對象
    return fortune.copyWith(
      zodiac: userZodiac,
      zodiacAffinity: zodiacAffinity,
      recommendations: allRecommendations,
    );
  }

  Future<Fortune> getDailyFortune(Zodiac zodiac, DateTime date) async {
    try {
      final response = await _apiClient.get(
        '/fortune/daily',
        queryParameters: {
          'zodiac': zodiac.name,
          'date': date.toIso8601String(),
        },
      );
      
      if (response.data == null) {
        throw Exception('獲取每日運勢失敗：伺服器返回空數據');
      }

      return Fortune.fromJson(response.data);
    } catch (e) {
      print('獲取每日運勢失敗: $e');
      rethrow;
    }
  }

  Future<List<Fortune>> getFortuneHistory(
    Zodiac zodiac,
    DateTime startDate,
    DateTime endDate, {
    int limit = 7,
  }) async {
    try {
      final response = await _apiClient.get(
        '/fortune/history',
        queryParameters: {
          'zodiac': zodiac.name,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'limit': limit,
        },
      );

      if (response.data == null) {
        throw Exception('獲取運勢歷史失敗：伺服器返回空數據');
      }

      final List<dynamic> historyData = response.data;
      return historyData.map((data) => Fortune.fromJson(data)).toList();
    } catch (e) {
      print('獲取運勢歷史失敗: $e');
      rethrow;
    }
  }
} 