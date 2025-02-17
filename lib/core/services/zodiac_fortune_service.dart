import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../utils/zodiac_image_helper.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/services/api_client.dart';
import 'package:all_lucky/core/models/api_response.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

final zodiacFortuneServiceProvider = Provider<ZodiacFortuneService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ZodiacFortuneService(apiClient);
});

class ZodiacFortuneService {
  final ApiClient _apiClient;

  ZodiacFortuneService(this._apiClient);

  // 生肖相性表（基礎分數）
  final Map<String, Map<String, int>> _baseAffinityScores = {
    '鼠': {'鼠': 80, '牛': 60, '虎': 70, '兔': 50, '龍': 90, '蛇': 60, '馬': 50, '羊': 70, '猴': 80, '雞': 60, '狗': 70, '豬': 90},
    '牛': {'鼠': 60, '牛': 80, '虎': 60, '兔': 70, '龍': 70, '蛇': 90, '馬': 60, '羊': 50, '猴': 60, '雞': 80, '狗': 70, '豬': 70},
    '虎': {'鼠': 70, '牛': 60, '虎': 80, '兔': 80, '龍': 90, '蛇': 60, '馬': 70, '羊': 70, '猴': 50, '雞': 60, '狗': 90, '豬': 60},
    '兔': {'鼠': 50, '牛': 70, '虎': 80, '兔': 80, '龍': 70, '蛇': 70, '馬': 80, '羊': 90, '猴': 60, '雞': 60, '狗': 70, '豬': 90},
    '龍': {'鼠': 90, '牛': 70, '虎': 90, '兔': 70, '龍': 80, '蛇': 90, '馬': 70, '羊': 60, '猴': 80, '雞': 80, '狗': 60, '豬': 70},
    '蛇': {'鼠': 60, '牛': 90, '虎': 60, '兔': 70, '龍': 90, '蛇': 80, '馬': 70, '羊': 70, '猴': 70, '雞': 90, '狗': 60, '豬': 50},
    '馬': {'鼠': 50, '牛': 60, '虎': 70, '兔': 80, '龍': 70, '蛇': 70, '馬': 80, '羊': 90, '猴': 70, '雞': 70, '狗': 80, '豬': 60},
    '羊': {'鼠': 70, '牛': 50, '虎': 70, '兔': 90, '龍': 60, '蛇': 70, '馬': 90, '羊': 80, '猴': 70, '雞': 70, '狗': 70, '豬': 80},
    '猴': {'鼠': 80, '牛': 60, '虎': 50, '兔': 60, '龍': 80, '蛇': 70, '馬': 70, '羊': 70, '猴': 80, '雞': 80, '狗': 60, '豬': 70},
    '雞': {'鼠': 60, '牛': 80, '虎': 60, '兔': 60, '龍': 80, '蛇': 90, '馬': 70, '羊': 70, '猴': 80, '雞': 80, '狗': 50, '豬': 60},
    '狗': {'鼠': 70, '牛': 70, '虎': 90, '兔': 70, '龍': 60, '蛇': 60, '馬': 80, '羊': 70, '猴': 60, '雞': 50, '狗': 80, '豬': 80},
    '豬': {'鼠': 90, '牛': 70, '虎': 60, '兔': 90, '龍': 70, '蛇': 50, '馬': 60, '羊': 80, '猴': 70, '雞': 60, '狗': 80, '豬': 80},
  };

  // 根據運勢類型獲取相關的生肖
  List<String> _getRelatedZodiacs(FortuneType fortuneType) {
    switch (fortuneType) {
      case FortuneType.career:
        return ['龍', '虎', '馬'];
      case FortuneType.study:
        return ['兔', '蛇', '雞'];
      case FortuneType.love:
        return ['羊', '豬', '兔'];
      case FortuneType.daily:
        return ['鼠', '龍', '猴'];
      case FortuneType.wealth:
        return ['龍', '蛇', '雞'];
      case FortuneType.health:
        return ['虎', '龍', '狗'];
      case FortuneType.travel:
        return ['馬', '猴', '豬'];
      case FortuneType.social:
        return ['兔', '羊', '猴'];
      case FortuneType.creative:
        return ['龍', '猴', '雞'];
    }
  }

  // 計算生肖相性分數
  Map<String, int> calculateZodiacAffinity(String zodiac, FortuneType fortuneType) {
    final baseScores = _baseAffinityScores[zodiac]!;
    final relatedZodiacs = _getRelatedZodiacs(fortuneType);
    
    final adjustedScores = Map<String, int>.from(baseScores);
    for (final relatedZodiac in relatedZodiacs) {
      if (adjustedScores.containsKey(relatedZodiac)) {
        adjustedScores[relatedZodiac] = (adjustedScores[relatedZodiac]! * 1.2).round();
      }
    }
    
    return adjustedScores;
  }

  Future<Fortune> getZodiacFortune(String zodiac, FortuneType fortuneType, DateTime date) async {
    final response = await _apiClient.get(
      '/fortunes/${fortuneType.name.toLowerCase()}',
      queryParameters: {
        'zodiac': zodiac,
        'date': date.toIso8601String(),
      },
    );
    
    if (response.isSuccess && response.data != null) {
      final fortune = Fortune.fromJson(response.data!);
      final zodiacAffinity = calculateZodiacAffinity(zodiac, fortuneType);
      final recommendations = generateZodiacRecommendations(zodiac, fortuneType, fortune.score);
      
      return fortune.copyWith(
        zodiac: Zodiac.fromString(zodiac),
        affinityScore: zodiacAffinity.values.reduce((a, b) => a + b) ~/ zodiacAffinity.length,
        recommendations: recommendations,
      );
    }
    
    throw Exception('Failed to get zodiac fortune: ${response.message}');
  }

  List<String> generateZodiacRecommendations(String zodiac, FortuneType fortuneType, int score) {
    final recommendations = <String>[];
    final relatedZodiacs = _getRelatedZodiacs(fortuneType);
    
    switch (fortuneType) {
      case FortuneType.career:
        if (score >= 80) {
          recommendations.add('今日適合與${relatedZodiacs.join('、')}生肖的人合作，有助於事業發展。');
          recommendations.add('可以主動尋求貴人相助，容易得到意外的工作機會。');
        } else if (score >= 60) {
          recommendations.add('工作中保持謹慎態度，避免衝動決策。');
          recommendations.add('與${relatedZodiacs.first}生肖的人合作可能會有突破性進展。');
        } else {
          recommendations.add('今日事業運較低，建議專注於日常工作，暫緩重要決策。');
          recommendations.add('可以向${relatedZodiacs.last}生肖的長輩請教意見。');
        }
        break;
        
      case FortuneType.study:
        if (score >= 80) {
          recommendations.add('今日學習效率極佳，適合挑戰困難的課題。');
          recommendations.add('與${relatedZodiacs.join('、')}生肖的同學討論問題會有新的見解。');
        } else if (score >= 60) {
          recommendations.add('保持專注力，避免分心，可以事半功倍。');
          recommendations.add('建議向${relatedZodiacs.first}生肖的人請教不懂的問題。');
        } else {
          recommendations.add('今日理解能力較弱，建議複習已掌握的內容。');
          recommendations.add('可以找${relatedZodiacs.last}生肖的朋友一起學習，互相督促。');
        }
        break;
        
      case FortuneType.love:
        if (score >= 80) {
          recommendations.add('今日桃花運旺盛，易與${relatedZodiacs.join('、')}生肖的異性產生緣分。');
          recommendations.add('適合參加社交活動，擴展人際圈。');
        } else if (score >= 60) {
          recommendations.add('感情運平穩，可以多關心對方，增進感情。');
          recommendations.add('與${relatedZodiacs.first}生肖的人互動會有意外收穫。');
        } else {
          recommendations.add('今日感情運較差，建議避免衝動的感情決定。');
          recommendations.add('可以向${relatedZodiacs.last}生肖的朋友傾訴心事。');
        }
        break;
        
      case FortuneType.daily:
        if (score >= 80) {
          recommendations.add('今日運勢極佳，適合嘗試新事物。');
          recommendations.add('與${relatedZodiacs.join('、')}生肖的人互動會帶來好運。');
        } else if (score >= 60) {
          recommendations.add('保持樂觀心態，平穩度過一天。');
          recommendations.add('可以尋求${relatedZodiacs.first}生肖朋友的建議。');
        } else {
          recommendations.add('今日運勢欠佳，凡事多加小心。');
          recommendations.add('建議多與${relatedZodiacs.last}生肖的人交流，轉運添福。');
        }
        break;

      case FortuneType.wealth:
        if (score >= 80) {
          recommendations.add('今日財運亨通，適合投資理財。');
          recommendations.add('與${relatedZodiacs.join('、')}生肖的人合作可能帶來意外收穫。');
        } else if (score >= 60) {
          recommendations.add('理財要謹慎，避免衝動消費。');
          recommendations.add('可以向${relatedZodiacs.first}生肖的人請教投資建議。');
        } else {
          recommendations.add('今日財運欠佳，建議避免大額支出。');
          recommendations.add('與${relatedZodiacs.last}生肖的人討論可能會有新的財運機會。');
        }
        break;

      case FortuneType.health:
        if (score >= 80) {
          recommendations.add('今日身體狀況良好，適合進行運動。');
          recommendations.add('可以和${relatedZodiacs.join('、')}生肖的朋友一起健身。');
        } else if (score >= 60) {
          recommendations.add('注意作息規律，保持良好的生活習慣。');
          recommendations.add('建議向${relatedZodiacs.first}生肖的人學習養生之道。');
        } else {
          recommendations.add('今日身體較易疲勞，要多休息。');
          recommendations.add('可以請教${relatedZodiacs.last}生肖的長輩保健知識。');
        }
        break;

      case FortuneType.travel:
        if (score >= 80) {
          recommendations.add('今日適合外出旅行，與${relatedZodiacs.join('、')}生肖的人同行會很愉快。');
          recommendations.add('可能會有意外的驚喜發現。');
        } else if (score >= 60) {
          recommendations.add('出行要注意安全，提前做好準備。');
          recommendations.add('可以請${relatedZodiacs.first}生肖的朋友推薦旅遊地點。');
        } else {
          recommendations.add('今日不適合長途旅行，建議改期。');
          recommendations.add('如果必須出行，可以諮詢${relatedZodiacs.last}生肖的人的建議。');
        }
        break;

      case FortuneType.social:
        if (score >= 80) {
          recommendations.add('今日人緣極佳，特別是與${relatedZodiacs.join('、')}生肖的人互動。');
          recommendations.add('適合參加社交活動，擴展人脈。');
        } else if (score >= 60) {
          recommendations.add('保持謙遜的態度，避免過於強勢。');
          recommendations.add('可以通過${relatedZodiacs.first}生肖的朋友認識新朋友。');
        } else {
          recommendations.add('今日社交運較弱，不適合參加重要社交場合。');
          recommendations.add('建議與${relatedZodiacs.last}生肖的知己好友小聚。');
        }
        break;

      case FortuneType.creative:
        if (score >= 80) {
          recommendations.add('今日靈感湧現，與${relatedZodiacs.join('、')}生肖的人合作能激發創意。');
          recommendations.add('適合嘗試新的創作方式。');
        } else if (score >= 60) {
          recommendations.add('保持開放的心態，多觀察生活中的細節。');
          recommendations.add('可以向${relatedZodiacs.first}生肖的人學習新技能。');
        } else {
          recommendations.add('今日創意較弱，建議整理已有的想法。');
          recommendations.add('與${relatedZodiacs.last}生肖的人交流可能會有新的啟發。');
        }
        break;
    }
    
    return recommendations;
  }

  Future<List<Fortune>> getZodiacFortuneHistory(String zodiac, FortuneType fortuneType, DateTime startDate, DateTime endDate) async {
    final response = await _apiClient.get(
      '/fortunes/${fortuneType.name.toLowerCase()}/history',
      queryParameters: {
        'zodiac': zodiac,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
    
    if (response.isSuccess && response.data != null) {
      final List<dynamic> fortuneList = response.data!;
      return fortuneList.map((data) {
        final fortune = Fortune.fromJson(data);
        final zodiacAffinity = calculateZodiacAffinity(zodiac, fortuneType);
        final recommendations = generateZodiacRecommendations(zodiac, fortuneType, fortune.score);
        
        return fortune.copyWith(
          zodiac: Zodiac.fromString(zodiac),
          affinityScore: zodiacAffinity.values.reduce((a, b) => a + b) ~/ zodiacAffinity.length,
          recommendations: recommendations,
        );
      }).toList();
    }
    
    throw Exception('Failed to get zodiac fortune history: ${response.message}');
  }

  Future<Fortune> getDailyFortune(Zodiac zodiac, DateTime date) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/fortune/daily',
        queryParameters: {
          'zodiac': zodiac.name,
          'date': date.toIso8601String(),
        },
        fromJson: (json) => json,
      );
      
      if (!response.isSuccess || response.data == null) {
        throw Exception('獲取每日運勢失敗：${response.message}');
      }

      return Fortune.fromJson(response.data!);
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
      final response = await _apiClient.get<List<dynamic>>(
        '/fortune/history',
        queryParameters: {
          'zodiac': zodiac.name,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'limit': limit,
        },
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception('獲取運勢歷史失敗：${response.message}');
      }

      return response.data!.map((data) => Fortune.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('獲取運勢歷史失敗: $e');
      rethrow;
    }
  }
} 