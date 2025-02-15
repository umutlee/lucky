import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_type.dart';
import '../models/zodiac.dart';
import '../utils/logger.dart';
import 'lunar_service.dart';
import 'time_factor_service.dart';
import 'zodiac_compatibility_service.dart';

/// 運勢評分服務提供者
final fortuneScoreServiceProvider = Provider<FortuneScoreService>((ref) {
  final lunarService = ref.watch(lunarServiceProvider);
  final timeFactorService = ref.watch(timeFactorServiceProvider);
  final zodiacCompatibilityService = ref.watch(zodiacCompatibilityServiceProvider);
  final logger = Logger('FortuneScoreService');
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
  final Logger _logger;

  // 分數權重配置
  static const _weights = {
    'time': 0.3,      // 時間因素權重
    'lunar': 0.3,     // 農曆因素權重
    'zodiac': 0.2,    // 生肖因素權重
    'seasonal': 0.2,  // 季節因素權重
  };

  // 分數閾值配置
  static const _thresholds = {
    'excellent': 0.8,  // 極佳
    'good': 0.7,      // 良好
    'normal': 0.6,    // 一般
    'poor': 0.4,      // 較差
  };

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
      _logger.info('開始計算運勢分數：${type.displayName}');

      // 計算各項因素的分數
      final factors = await _calculateAllFactors(
        date: date,
        type: type,
        zodiac: zodiac,
        targetZodiac: targetZodiac,
      );

      // 計算加權總分
      final weightedScore = _calculateWeightedScore(factors);
      
      // 生成建議
      final suggestions = _generateSuggestions(
        type: type,
        score: weightedScore,
        factors: factors,
      );

      _logger.info('運勢計算完成，總分：${(weightedScore * 100).round()}');

      // 返回結果
      return (
        score: (weightedScore * 100).round(),
        factors: factors,
        suggestions: suggestions,
      );
    } catch (e, stack) {
      _logger.error('計算運勢分數失敗', e, stack);
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

  /// 計算所有因素分數
  Future<Map<String, double>> _calculateAllFactors({
    required DateTime date,
    required FortuneType type,
    String? zodiac,
    String? targetZodiac,
  }) async {
    final timeScore = _timeFactorService.calculateTimeScore(date, type);
    final lunarScore = await _calculateLunarScore(date, type);
    final zodiacScore = await _calculateZodiacScore(
      date: date,
      type: type,
      zodiac: zodiac,
      targetZodiac: targetZodiac,
    );
    final seasonalScore = _calculateSeasonalScore(date, type);

    return {
      '時間因素': timeScore,
      '農曆因素': lunarScore,
      '生肖因素': zodiacScore,
      '季節因素': seasonalScore,
    };
  }

  /// 計算加權總分
  double _calculateWeightedScore(Map<String, double> factors) {
    return factors.entries.fold<double>(0.0, (sum, factor) {
      final weight = _weights[factor.key.split('因素')[0]] ?? 0.0;
      return sum + factor.value * weight;
    });
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

      // 根據運勢類型調整
      baseScore *= switch (type) {
        FortuneType.daily => 1.0,
        FortuneType.love when lunarDate.festival == '七夕節' => 1.5,
        FortuneType.career when lunarDate.day == 1 => 1.3,
        FortuneType.study when lunarDate.day == 8 => 1.2,
        _ => 1.0,
      };

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
          .calculateCompatibility(
            Zodiac.fromString(zodiac),
            Zodiac.fromString(targetZodiac),
            type,
          );
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
    try {
      final month = date.month;
      
      // 基礎季節分數
      double baseScore = switch (month) {
        3 || 4 || 5 => 0.9,    // 春季
        6 || 7 || 8 => 0.8,    // 夏季
        9 || 10 || 11 => 0.9,  // 秋季
        _ => 0.7,              // 冬季
      };
      
      // 根據運勢類型調整分數
      baseScore *= switch (type) {
        FortuneType.study => switch (month) {
          3 || 4 || 5 || 9 || 10 || 11 => 1.2,  // 春秋季學習效果好
          _ => 1.0,
        },
        FortuneType.love => switch (month) {
          3 || 4 || 5 => 1.3,  // 春季桃花運旺
          _ => 1.0,
        },
        FortuneType.career => switch (month) {
          9 || 10 || 11 => 1.2,  // 秋季事業運好
          _ => 1.0,
        },
        _ => 1.0,
      };
      
      return baseScore.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算季節分數失敗: $e');
      return 0.7;
    }
  }

  /// 生成運勢建議
  List<String> _generateSuggestions({
    required FortuneType type,
    required double score,
    required Map<String, double> factors,
  }) {
    final suggestions = <String>[];
    
    // 根據總分給出建議
    suggestions.add(_getOverallSuggestion(score));
    
    // 添加因素相關建議
    suggestions.addAll(_getFactorSuggestions(factors));
    
    // 添加類型特定建議
    suggestions.addAll(_getTypeSuggestions(type, score));
    
    return suggestions;
  }

  /// 獲取總體建議
  String _getOverallSuggestion(double score) {
    return switch (score) {
      >= _thresholds['excellent']! => '今日運勢極佳，適合大展拳腳',
      >= _thresholds['good']! => '運勢不錯，可以嘗試新事物',
      >= _thresholds['normal']! => '運勢平平，宜按部就班行事',
      >= _thresholds['poor']! => '運勢欠佳，建議謹慎行事',
      _ => '今日運勢不佳，宜靜養休息',
    };
  }

  /// 獲取因素相關建議
  List<String> _getFactorSuggestions(Map<String, double> factors) {
    final suggestions = <String>[];
    
    if (factors['時間因素']! >= _thresholds['good']!) {
      suggestions.add('當前時段最適合行動');
    }
    
    if (factors['農曆因素']! >= _thresholds['good']!) {
      suggestions.add('今日為傳統吉日');
    }
    
    if (factors['生肖因素']! >= _thresholds['good']!) {
      suggestions.add('生肖相性良好');
    }
    
    if (factors['季節因素']! >= _thresholds['good']!) {
      suggestions.add('季節因素有利');
    }
    
    return suggestions;
  }

  /// 獲取類型特定建議
  List<String> _getTypeSuggestions(FortuneType type, double score) {
    if (score < _thresholds['good']!) return [];
    
    return switch (type) {
      FortuneType.study => [
        '適合學習新知識',
        '考試運勢不錯',
      ],
      FortuneType.career => [
        '職場發展機會良好',
        '適合談判或簽約',
      ],
      FortuneType.love => [
        '桃花運旺盛',
        '適合表達心意',
      ],
      _ => [
        '整體運勢良好',
      ],
    };
  }
} 