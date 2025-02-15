import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import '../models/zodiac.dart';
import '../models/fortune_type.dart';
import '../utils/logger.dart';

final zodiacCompatibilityServiceProvider = Provider<ZodiacCompatibilityService>((ref) {
  final logger = Logger('ZodiacCompatibilityService');
  return ZodiacCompatibilityService(logger);
});

class ZodiacCompatibilityService {
  final Logger _logger;

  ZodiacCompatibilityService(this._logger);

  /// 計算生肖相性分數
  Future<double> calculateCompatibility(
    Zodiac zodiac1,
    Zodiac zodiac2,
    FortuneType fortuneType,
  ) async {
    try {
      // 使用 lunar 包的生肖相合相沖計算
      final lunar1 = Lunar.fromYmd(2024, 1, 1); // 使用固定日期，只需要生肖信息
      final lunar2 = Lunar.fromYmd(2024, 1, 1);
      
      // 獲取生肖
      final animal1 = _getAnimalFromZodiac(zodiac1);
      final animal2 = _getAnimalFromZodiac(zodiac2);
      
      // 計算基礎相性分數
      double baseScore = _calculateBaseCompatibility(animal1, animal2);
      
      // 根據五行相生相剋調整分數
      final wuxing1 = lunar1.getYearWuXing();
      final wuxing2 = lunar2.getYearWuXing();
      baseScore = _adjustScoreByWuXing(baseScore, wuxing1, wuxing2);
      
      // 根據運勢類型調整分數
      final adjustedScore = _adjustScoreByFortuneType(baseScore, fortuneType);
      
      return adjustedScore.clamp(0.0, 100.0);
    } catch (e, stackTrace) {
      _logger.error('計算生肖相性時發生錯誤', e, stackTrace);
      return 60.0; // 返回中等分數作為預設值
    }
  }

  /// 從生肖枚舉獲取對應的生肖名稱
  String _getAnimalFromZodiac(Zodiac zodiac) {
    return switch (zodiac) {
      Zodiac.rat => '鼠',
      Zodiac.ox => '牛',
      Zodiac.tiger => '虎',
      Zodiac.rabbit => '兔',
      Zodiac.dragon => '龍',
      Zodiac.snake => '蛇',
      Zodiac.horse => '馬',
      Zodiac.goat => '羊',
      Zodiac.monkey => '猴',
      Zodiac.rooster => '雞',
      Zodiac.dog => '狗',
      Zodiac.pig => '豬',
    };
  }

  /// 計算基礎相性分數
  double _calculateBaseCompatibility(String animal1, String animal2) {
    // 相合生肖
    const compatiblePairs = {
      '鼠': ['牛', '龍', '猴'],
      '牛': ['鼠', '蛇', '雞'],
      '虎': ['豬', '馬', '狗'],
      '兔': ['羊', '狗', '豬'],
      '龍': ['鼠', '猴', '雞'],
      '蛇': ['牛', '雞', '龍'],
      '馬': ['虎', '羊', '狗'],
      '羊': ['兔', '馬', '豬'],
      '猴': ['鼠', '龍', '蛇'],
      '雞': ['牛', '蛇', '龍'],
      '狗': ['虎', '兔', '馬'],
      '豬': ['虎', '兔', '羊'],
    };

    // 相沖生肖
    const conflictPairs = {
      '鼠': ['馬'],
      '牛': ['羊'],
      '虎': ['猴'],
      '兔': ['雞'],
      '龍': ['狗'],
      '蛇': ['豬'],
      '馬': ['鼠'],
      '羊': ['牛'],
      '猴': ['虎'],
      '雞': ['兔'],
      '狗': ['龍'],
      '豬': ['蛇'],
    };

    // 相同生肖
    if (animal1 == animal2) {
      return 80.0;
    }

    // 相合生肖
    if (compatiblePairs[animal1]?.contains(animal2) ?? false) {
      return 90.0;
    }

    // 相沖生肖
    if (conflictPairs[animal1]?.contains(animal2) ?? false) {
      return 40.0;
    }

    // 其他情況
    return 70.0;
  }

  /// 根據五行相生相剋調整分數
  double _adjustScoreByWuXing(double score, String wuxing1, String wuxing2) {
    // 五行相生
    const generating = {
      '木': '火',
      '火': '土',
      '土': '金',
      '金': '水',
      '水': '木',
    };

    // 五行相剋
    const controlling = {
      '木': '土',
      '土': '水',
      '水': '火',
      '火': '金',
      '金': '木',
    };

    // 相生加分
    if (generating[wuxing1] == wuxing2) {
      return score * 1.1;
    }

    // 被生加分（較小）
    if (generating[wuxing2] == wuxing1) {
      return score * 1.05;
    }

    // 相剋減分
    if (controlling[wuxing1] == wuxing2) {
      return score * 0.9;
    }

    // 被剋減分（較大）
    if (controlling[wuxing2] == wuxing1) {
      return score * 0.85;
    }

    return score;
  }

  /// 根據運勢類型調整分數
  double _adjustScoreByFortuneType(double score, FortuneType fortuneType) {
    return switch (fortuneType) {
      FortuneType.study => score * 1.2,
      FortuneType.career => score * 1.1,
      FortuneType.love => score * 1.3,
      FortuneType.wealth => score * 1.15,
      FortuneType.health => score * 1.1,
      FortuneType.travel => score * 1.05,
      FortuneType.social => score * 1.2,
      FortuneType.creativity => score * 1.1,
      FortuneType.daily => score,
    };
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
    FortuneType type,
    double score,
  ) {
    final lunar = Lunar.fromDate(DateTime.now());
    final suggestions = <String>[];

    switch (type) {
      case FortuneType.career:
        if (score >= 80) {
          suggestions.add('事業合作能相輔相成，共創佳績');
          suggestions.add('建議在${lunar.getDayPositions().firstOrNull ?? ""}方位辦公');
        } else {
          suggestions.add('工作上需要多溝通，理解對方想法');
          suggestions.add('避開${lunar.getDayChongDesc()}方位');
        }

      case FortuneType.study:
        if (score >= 80) {
          suggestions.add('學習上能互相督促，共同進步');
          suggestions.add('適合在${lunar.getDayXiu()}時段討論學習');
        } else {
          suggestions.add('學習方式可能有差異，需要互相適應');
          suggestions.add('建議參考${lunar.getDayPositions().firstOrNull ?? ""}方位擺放書桌');
        }

      case FortuneType.love:
        if (score >= 80) {
          suggestions.add('感情發展順利，易產生共鳴');
          suggestions.add('宜在${lunar.getDayPositions().firstOrNull ?? ""}方向相會');
        } else {
          suggestions.add('感情需要更多包容與理解');
          suggestions.add('避免在${lunar.getDayChongDesc()}方向約會');
        }

      case FortuneType.wealth:
        suggestions.add('財運提示：${lunar.getDayPengZuGan()}');
        suggestions.add('開運方位：${lunar.getDayPositions().firstOrNull ?? ""}');

      case FortuneType.health:
        suggestions.add('今日養生要點：${lunar.getDayTaishen()}');
        suggestions.add('避免前往：${lunar.getDayChongDesc()}');

      case FortuneType.travel:
        suggestions.add('出行建議：往${lunar.getDayPositions().firstOrNull ?? ""}方向');
        suggestions.add('避開：${lunar.getDayChongDesc()}');

      case FortuneType.social:
        suggestions.add('人際運勢：${lunar.getDayXiu()}');
        suggestions.add('貴人方位：${lunar.getDayPositions().firstOrNull}');

      case FortuneType.creativity:
        if (lunar.getDayWuXing() == '火') {
          suggestions.add('靈感充沛，適合創作');
        }
        suggestions.add('創意空間建議：${lunar.getDayPositions().firstOrNull ?? ""}');

      case FortuneType.daily:
        suggestions.add('今日吉時：${lunar.getTimeZhi()}');
        suggestions.add('開運建議：${lunar.getDayYi().firstOrNull ?? "平和心態"}');
    }

    return suggestions;
  }
} 