import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_type.dart';
import 'lunar_service.dart';
import 'time_factor_service.dart';
import 'zodiac_compatibility_service.dart';
import 'logger_service.dart';

/// 運勢評分服務提供者
final fortuneScoreServiceProvider = Provider<FortuneScoreService>((ref) {
  final lunarService = ref.watch(lunarServiceProvider);
  final timeFactorService = ref.watch(timeFactorServiceProvider);
  final zodiacCompatibilityService = ref.watch(zodiacCompatibilityServiceProvider);
  final logger = ref.watch(loggerServiceProvider);
  return FortuneScoreService(
    lunarService,
    timeFactorService,
    zodiacCompatibilityService,
    logger,
  );
});

/// 運勢評分服務
class FortuneScoreService {
  final LunarService _lunarService;
  final TimeFactorService _timeFactorService;
  final ZodiacCompatibilityService _zodiacCompatibilityService;
  final LoggerService _logger;

  FortuneScoreService(
    this._lunarService,
    this._timeFactorService,
    this._zodiacCompatibilityService,
    this._logger,
  );

  /// 計算綜合運勢分數
  /// 
  /// [date] 日期
  /// [type] 運勢類型
  /// [zodiac] 生肖（可選）
  /// [targetZodiac] 目標生肖（可選，用於計算相性）
  Future<({
    int score,
    Map<String, double> factors,
    List<String> suggestions,
  })> calculateFortuneScore({
    required DateTime date,
    required FortuneType type,
    String? zodiac,
    String? targetZodiac,
  }) async {
    try {
      // 計算各項因素的分數
      final timeScore = _timeFactorService.calculateTimeScore(date, type);
      final lunarScore = await _calculateLunarScore(date, type);
      final zodiacScore = await _calculateZodiacScore(
        date: date,
        type: type,
        zodiac: zodiac,
        targetZodiac: targetZodiac,
      );
      final seasonalScore = _calculateSeasonalScore(date, type);

      // 權重配置
      const weights = {
        'time': 0.3,      // 時間因素權重
        'lunar': 0.3,     // 農曆因素權重
        'zodiac': 0.2,    // 生肖因素權重
        'seasonal': 0.2,  // 季節因素權重
      };

      // 計算加權總分
      final weightedScore = (
        timeScore * weights['time']! +
        lunarScore * weights['lunar']! +
        zodiacScore * weights['zodiac']! +
        seasonalScore * weights['seasonal']!
      );

      // 生成建議
      final suggestions = _generateSuggestions(
        type,
        weightedScore,
        {
          'timeScore': timeScore,
          'lunarScore': lunarScore,
          'zodiacScore': zodiacScore,
          'seasonalScore': seasonalScore,
        },
      );

      // 返回結果
      return (
        score: (weightedScore * 100).round(),
        factors: {
          '時間因素': timeScore,
          '農曆因素': lunarScore,
          '生肖因素': zodiacScore,
          '季節因素': seasonalScore,
        },
        suggestions: suggestions,
      );
    } catch (e, stack) {
      _logger.error('計算運勢分數失敗', e, stack);
      // 返回預設值
      return (
        score: 60,
        factors: {
          '時間因素': 0.6,
          '農曆因素': 0.6,
          '生肖因素': 0.6,
          '季節因素': 0.6,
        },
        suggestions: ['暫時無法計算詳細運勢，建議謹慎行事'],
      );
    }
  }

  /// 計算農曆因素分數
  Future<double> _calculateLunarScore(DateTime date, FortuneType type) async {
    try {
      final lunarDate = _lunarService.solarToLunar(date);
      
      // 基礎分數（根據農曆日期）
      double baseScore = switch (lunarDate.day) {
        1 || 15 => 1.0,           // 初一、十五
        8 || 23 => 0.9,           // 初八、廿三
        3 || 7 || 13 || 27 => 0.8, // 其他傳統吉日
        <= 2 || >= 29 => 0.6,     // 月初月末
        _ => 0.7,                 // 其他日期
      };

      // 節氣加成
      if (lunarDate.solarTerm != null) {
        baseScore *= 1.2;
      }

      // 節日加成
      if (lunarDate.festival != null) {
        baseScore *= 1.3;
      }

      // 確保分數在 0-1 範圍內
      return baseScore.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算農曆分數失敗: $e');
      return 0.6;
    }
  }

  /// 計算生肖因素分數
  Future<double> _calculateZodiacScore({
    required DateTime date,
    required FortuneType type,
    String? zodiac,
    String? targetZodiac,
  }) async {
    if (zodiac == null) return 0.7;

    try {
      double score = 0.7; // 基礎分數

      // 計算生肖相性（如果有目標生肖）
      if (targetZodiac != null) {
        final compatibility = await _zodiacCompatibilityService
          .calculateCompatibility(zodiac, targetZodiac, type);
        score = compatibility / 100;
      }

      // 根據運勢類型調整分數
      score *= switch (type) {
        FortuneType.career => 1.2,  // 事業運加成
        FortuneType.love => 1.3,    // 感情運加成
        FortuneType.study => 1.1,   // 學業運加成
        _ => 1.0,                   // 其他類型
      };

      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算生肖分數失敗: $e');
      return 0.6;
    }
  }

  /// 計算季節因素分數
  double _calculateSeasonalScore(DateTime date, FortuneType type) {
    final month = date.month;
    
    // 基於不同運勢類型計算季節分數
    return switch (type) {
      FortuneType.study => switch (month) {
        3 || 4 || 5 || 9 || 10 || 11 => 0.9, // 春秋季節最適合學習
        6 || 7 || 8 => 0.6,                  // 夏季較難專注
        _ => 0.7,                            // 冬季一般
      },
      FortuneType.career => switch (month) {
        3 || 4 || 9 => 0.9,    // 春季初和秋季初最佳
        5 || 10 => 0.8,        // 春季末和秋季中
        6 || 7 || 8 => 0.7,    // 夏季一般
        _ => 0.6,              // 冬季較差
      },
      FortuneType.love => switch (month) {
        3 || 4 || 5 => 0.9,    // 春季最適合
        9 || 10 || 11 => 0.8,  // 秋季次之
        6 || 7 || 8 => 0.7,    // 夏季一般
        _ => 0.6,              // 冬季較差
      },
      _ => switch (month) {
        3 || 4 || 5 || 9 || 10 || 11 => 0.8, // 春秋季節
        6 || 7 || 8 => 0.7,                  // 夏季
        _ => 0.6,                            // 冬季
      },
    };
  }

  /// 生成運勢建議
  List<String> _generateSuggestions(
    FortuneType type,
    double score,
    Map<String, double> factors,
  ) {
    final suggestions = <String>[];

    // 根據總分給出總體建議
    suggestions.add(switch (score) {
      >= 0.9 => '今日運勢極佳，適合大展宏圖',
      >= 0.8 => '今日運勢良好，可以放心行動',
      >= 0.7 => '今日運勢尚可，保持平常心',
      >= 0.6 => '今日運勢平平，宜謹慎行事',
      _ => '今日運勢欠佳，不宜冒險',
    });

    // 根據各項因素分數給出具體建議
    if (factors['timeScore']! >= 0.8) {
      suggestions.add('當前時段最適合行動');
    }

    if (factors['lunarScore']! >= 0.8) {
      suggestions.add('今日農曆日期吉利');
    }

    if (factors['zodiacScore']! >= 0.8) {
      suggestions.add('生肖相性良好，可以放心合作');
    }

    // 根據運勢類型給出特定建議
    suggestions.add(switch (type) {
      FortuneType.study when score >= 0.8 => '今日最適合學習和考試',
      FortuneType.study => '建議複習和鞏固知識',
      FortuneType.career when score >= 0.8 => '事業發展機會良多',
      FortuneType.career => '工作宜穩健發展',
      FortuneType.love when score >= 0.8 => '感情發展機會良多',
      FortuneType.love => '感情發展需要耐心',
      _ when score >= 0.8 => '整體運勢良好',
      _ => '凡事宜謹慎',
    });

    return suggestions;
  }
} 