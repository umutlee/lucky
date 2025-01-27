import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';

final zodiacCompatibilityServiceProvider = Provider<ZodiacCompatibilityService>((ref) {
  return ZodiacCompatibilityService();
});

class ZodiacCompatibilityService {
  // 五行相生關係
  static const Map<String, String> _elementGenerates = {
    '木': '火',
    '火': '土',
    '土': '金',
    '金': '水',
    '水': '木',
  };

  // 五行相剋關係
  static const Map<String, String> _elementOvercomes = {
    '木': '土',
    '土': '水',
    '水': '火',
    '火': '金',
    '金': '木',
  };

  // 生肖相性基礎分數
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

  // 運勢類型相關生肖
  final Map<FortuneType, List<String>> _fortuneTypeZodiacs = {
    FortuneType.career: ['龍', '虎', '馬', '猴'],
    FortuneType.study: ['兔', '蛇', '雞', '牛'],
    FortuneType.love: ['羊', '豬', '兔', '龍'],
    FortuneType.daily: ['鼠', '龍', '猴', '豬'],
  };

  /// 計算兩個生肖的相性分數
  /// 
  /// [zodiac1] 第一個生肖
  /// [zodiac2] 第二個生肖
  /// [fortuneType] 運勢類型
  /// [date] 日期（可選）
  double calculateCompatibility(
    Zodiac zodiac1,
    Zodiac zodiac2,
    FortuneType fortuneType, [
    DateTime? date,
  ]) {
    try {
      double score = 0.0;

      // 1. 基礎相性分數 (40%)
      final baseScore = _baseAffinityScores[zodiac1.name]?[zodiac2.name] ?? 60;
      score += baseScore * 0.4;

      // 2. 五行相性 (30%)
      final elementScore = _calculateElementCompatibility(zodiac1.element, zodiac2.element);
      score += elementScore * 0.3;

      // 3. 運勢類型加成 (20%)
      final fortuneTypeScore = _calculateFortuneTypeBonus(
        zodiac1.name,
        zodiac2.name,
        fortuneType,
      );
      score += fortuneTypeScore * 0.2;

      // 4. 時間因素 (10%)
      if (date != null) {
        final timeScore = _calculateTimeFactorScore(zodiac1, zodiac2, date);
        score += timeScore * 0.1;
      } else {
        // 如果沒有提供日期，將權重分配給基礎分數
        score += baseScore * 0.1;
      }

      return score;
    } catch (e, stackTrace) {
      logger.error('計算生肖相性時發生錯誤', error: e, stackTrace: stackTrace);
      return 60.0; // 返回中等分數作為默認值
    }
  }

  /// 計算五行相性分數
  double _calculateElementCompatibility(String element1, String element2) {
    if (element1 == element2) {
      return 80.0; // 同五行
    }

    if (_elementGenerates[element1] == element2) {
      return 90.0; // 相生關係
    }

    if (_elementOvercomes[element1] == element2) {
      return 60.0; // 相剋關係
    }

    return 70.0; // 其他關係
  }

  /// 計算運勢類型加成分數
  double _calculateFortuneTypeBonus(
    String zodiac1,
    String zodiac2,
    FortuneType fortuneType,
  ) {
    final relatedZodiacs = _fortuneTypeZodiacs[fortuneType] ?? [];
    
    bool isZodiac1Related = relatedZodiacs.contains(zodiac1);
    bool isZodiac2Related = relatedZodiacs.contains(zodiac2);

    if (isZodiac1Related && isZodiac2Related) {
      return 95.0; // 兩個生肖都與運勢類型相關
    } else if (isZodiac1Related || isZodiac2Related) {
      return 85.0; // 其中一個生肖與運勢類型相關
    }

    return 75.0; // 都不相關
  }

  /// 計算時間因素分數
  double _calculateTimeFactorScore(Zodiac zodiac1, Zodiac zodiac2, DateTime date) {
    try {
      // 1. 檢查是否在生肖年
      final year = date.year;
      final currentZodiac = ((year - 4) % 12); // 計算當年生肖
      final zodiac1Index = Zodiac.values.indexOf(zodiac1);
      final zodiac2Index = Zodiac.values.indexOf(zodiac2);

      if (currentZodiac == zodiac1Index || currentZodiac == zodiac2Index) {
        return 90.0; // 本命年加成
      }

      // 2. 檢查月份相性
      final month = date.month;
      final monthZodiacIndex = (month + 1) % 12; // 每個月對應的生肖

      if (monthZodiacIndex == zodiac1Index || monthZodiacIndex == zodiac2Index) {
        return 85.0; // 當月生肖加成
      }

      // 3. 檢查日支相性
      final day = date.day;
      final dayZodiacIndex = day % 12;

      if (dayZodiacIndex == zodiac1Index || dayZodiacIndex == zodiac2Index) {
        return 80.0; // 當日生肖加成
      }

      return 75.0; // 一般情況
    } catch (e) {
      return 75.0; // 發生錯誤時返回中等分數
    }
  }

  /// 獲取相性描述
  String getCompatibilityDescription(double score) {
    if (score >= 90) {
      return '非常相配，能夠互相扶持，共創佳績';
    } else if (score >= 80) {
      return '相性良好，可以互補不足，共同進步';
    } else if (score >= 70) {
      return '相處和睦，保持理解與包容的態度';
    } else if (score >= 60) {
      return '普通相性，需要多溝通來增進了解';
    } else {
      return '相性略低，但真誠相待能化解分歧';
    }
  }

  /// 獲取運勢類型相關的建議
  List<String> getFortuneTypeAdvice(
    Zodiac zodiac1,
    Zodiac zodiac2,
    FortuneType fortuneType,
    double score,
  ) {
    final advice = <String>[];
    final relatedZodiacs = _fortuneTypeZodiacs[fortuneType] ?? [];

    switch (fortuneType) {
      case FortuneType.career:
        if (score >= 80) {
          advice.add('事業合作能相輔相成，共創佳績');
          if (relatedZodiacs.contains(zodiac1.name) || relatedZodiacs.contains(zodiac2.name)) {
            advice.add('特別適合在職場上互相提攜，發揮各自優勢');
          }
        } else {
          advice.add('工作上需要多溝通，理解對方想法');
          advice.add('建立明確的分工機制，避免誤解');
        }
        break;

      case FortuneType.study:
        if (score >= 80) {
          advice.add('學習上能互相督促，共同進步');
          if (relatedZodiacs.contains(zodiac1.name) || relatedZodiacs.contains(zodiac2.name)) {
            advice.add('可以組成學習小組，分享學習方法');
          }
        } else {
          advice.add('學習方式可能有差異，需要互相適應');
          advice.add('建議找到共同的學習興趣點');
        }
        break;

      case FortuneType.love:
        if (score >= 80) {
          advice.add('感情發展順利，易產生共鳴');
          if (relatedZodiacs.contains(zodiac1.name) || relatedZodiacs.contains(zodiac2.name)) {
            advice.add('特別適合培養共同興趣，增進感情');
          }
        } else {
          advice.add('感情需要更多包容與理解');
          advice.add('保持耐心，慢慢培養默契');
        }
        break;

      case FortuneType.daily:
        if (score >= 80) {
          advice.add('日常相處融洽，能互相照應');
          if (relatedZodiacs.contains(zodiac1.name) || relatedZodiacs.contains(zodiac2.name)) {
            advice.add('共同活動能帶來好運');
          }
        } else {
          advice.add('日常生活中要多體諒對方');
          advice.add('建立良好的溝通習慣');
        }
        break;
    }

    return advice;
  }
} 