import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/fortune_type.dart';
import '../models/zodiac.dart';
import '../utils/logger.dart';

final fortuneRecommendationServiceProvider = Provider<FortuneRecommendationService>(
  (ref) => FortuneRecommendationService(),
);

/// 運勢推薦服務
class FortuneRecommendationService {
  final _logger = Logger('FortuneRecommendationService');

  /// 生成運勢推薦
  List<String> generateRecommendations(Fortune fortune) {
    try {
      final recommendations = <String>[];
      
      // 添加基礎運勢建議
      recommendations.addAll(_generateBaseRecommendations(fortune));
      
      // 根據運勢類型添加特定建議
      recommendations.addAll(_generateTypeSpecificRecommendations(fortune));
      
      // 添加生肖相關建議
      if (fortune.zodiac != null) {
        recommendations.addAll(_generateZodiacRecommendations(fortune));
      }
      
      // 添加時間相關建議
      recommendations.addAll(_generateTimeBasedRecommendations(fortune));
      
      // 確保建議數量適中（最多5條）
      if (recommendations.length > 5) {
        recommendations.length = 5;
      }
      
      return recommendations;
    } catch (e, stack) {
      _logger.error('生成運勢推薦失敗', e, stack);
      return ['保持平常心，按部就班行事'];
    }
  }

  /// 生成基礎運勢建議
  List<String> _generateBaseRecommendations(Fortune fortune) {
    final recommendations = <String>[];
    
    if (fortune.score >= 90) {
      recommendations.add('今日運勢極佳，適合大展宏圖');
      recommendations.add('重要決策可以放心進行');
    } else if (fortune.score >= 80) {
      recommendations.add('運勢不錯，可以嘗試新事物');
      recommendations.add('適合推進重要計劃');
    } else if (fortune.score >= 70) {
      recommendations.add('運勢平穩，按計劃行事即可');
      recommendations.add('注意把握機會，保持積極態度');
    } else if (fortune.score >= 60) {
      recommendations.add('運勢平平，宜穩健行事');
      recommendations.add('避免冒險，專注日常事務');
    } else {
      recommendations.add('運勢欠佳，凡事需謹慎');
      recommendations.add('建議低調行事，避免衝動');
    }
    
    return recommendations;
  }

  /// 生成特定類型的運勢建議
  List<String> _generateTypeSpecificRecommendations(Fortune fortune) {
    final recommendations = <String>[];
    
    switch (fortune.type) {
      case FortuneType.study:
        if (fortune.studyFortune != null) {
          recommendations.add('今日學習重點：${fortune.studyFortune!.bestSubjects.join("、")}');
          recommendations.add('建議學習時段：${fortune.studyFortune!.studyTips.first}');
        }
        break;
        
      case FortuneType.career:
        if (fortune.careerFortune != null) {
          recommendations.add('職場建議：${fortune.careerFortune!.careerTips.first}');
          if (fortune.careerFortune!.investmentTips.isNotEmpty) {
            recommendations.add('投資建議：${fortune.careerFortune!.investmentTips.first}');
          }
        }
        break;
        
      case FortuneType.love:
        if (fortune.loveFortune != null) {
          recommendations.add('感情建議：${fortune.loveFortune!.relationshipTips.first}');
          if (fortune.loveFortune!.dateTips.isNotEmpty) {
            recommendations.add('約會建議：${fortune.loveFortune!.dateTips.first}');
          }
        }
        break;
        
      case FortuneType.daily:
        if (fortune.dailyFortune != null) {
          if (fortune.dailyFortune!.goodActivities.isNotEmpty) {
            recommendations.add('宜：${fortune.dailyFortune!.goodActivities.join("、")}');
          }
          if (fortune.dailyFortune!.badActivities.isNotEmpty) {
            recommendations.add('忌：${fortune.dailyFortune!.badActivities.join("、")}');
          }
        }
        break;
    }
    
    return recommendations;
  }

  /// 生成生肖相關建議
  List<String> _generateZodiacRecommendations(Fortune fortune) {
    final recommendations = <String>[];
    
    if (fortune.zodiac != null) {
      // 添加生肖相性建議
      recommendations.add('今日相配生肖：${_getCompatibleZodiacs(fortune.zodiac!).join("、")}');
      
      // 添加方位建議
      if (fortune.luckyDirections.isNotEmpty) {
        recommendations.add('今日宜往${fortune.luckyDirections.join("、")}方向行事');
      }
    }
    
    return recommendations;
  }

  /// 生成時間相關建議
  List<String> _generateTimeBasedRecommendations(Fortune fortune) {
    final recommendations = <String>[];
    
    if (fortune.luckyTimes.isNotEmpty) {
      recommendations.add('今日吉時：${fortune.luckyTimes.join("、")}');
    }
    
    // 根據當前時間添加建議
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 6 && hour < 9) {
      recommendations.add('早晨適合規劃今日行程');
    } else if (hour >= 9 && hour < 12) {
      recommendations.add('上午是處理重要事務的好時機');
    } else if (hour >= 14 && hour < 17) {
      recommendations.add('下午適合社交和商務活動');
    } else if (hour >= 19 && hour < 22) {
      recommendations.add('晚上適合放鬆心情，做些休閒活動');
    }
    
    return recommendations;
  }

  /// 獲取相配生肖
  List<String> _getCompatibleZodiacs(Zodiac zodiac) {
    switch (zodiac) {
      case Zodiac.rat:
        return ['龍', '猴'];
      case Zodiac.ox:
        return ['蛇', '雞'];
      case Zodiac.tiger:
        return ['馬', '狗'];
      case Zodiac.rabbit:
        return ['羊', '豬'];
      case Zodiac.dragon:
        return ['鼠', '猴'];
      case Zodiac.snake:
        return ['牛', '雞'];
      case Zodiac.horse:
        return ['虎', '羊'];
      case Zodiac.goat:
        return ['兔', '豬'];
      case Zodiac.monkey:
        return ['鼠', '龍'];
      case Zodiac.rooster:
        return ['牛', '蛇'];
      case Zodiac.dog:
        return ['虎', '兔'];
      case Zodiac.pig:
        return ['兔', '羊'];
    }
  }
} 