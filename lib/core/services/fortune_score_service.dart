import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
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

      // 使用 lunar 包計算基礎運勢
      final lunar = Lunar.fromDate(date);
      final dayFortune = lunar.getDayFortune();
      final baseFortune = dayFortune.getScore() / 100.0;

      // 計算各項因素的分數
      final factors = await _calculateAllFactors(
        date: date,
        type: type,
        zodiac: zodiac,
        targetZodiac: targetZodiac,
        baseFortune: baseFortune,
      );

      // 計算加權總分
      final weightedScore = _calculateWeightedScore(factors);
      
      // 生成建議
      final suggestions = _generateSuggestions(
        lunar: lunar,
        type: type,
        score: weightedScore,
        factors: factors,
      );

      _logger.info('運勢計算完成，總分：${(weightedScore * 100).round()}');

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
    required double baseFortune,
  }) async {
    final lunar = Lunar.fromDate(date);
    
    // 時間因素
    final timeScore = _timeFactorService.calculateTimeScore(date, type);
    
    // 農曆因素（包含節氣、節日等）
    final lunarScore = _calculateLunarScore(lunar, type);
    
    // 生肖因素
    final zodiacScore = await _calculateZodiacScore(
      date: date,
      type: type,
      zodiac: zodiac,
      targetZodiac: targetZodiac,
    );
    
    // 五行因素
    final wuxingScore = _calculateWuxingScore(lunar, type);

    return {
      '時間因素': timeScore,
      '農曆因素': lunarScore,
      '生肖因素': zodiacScore,
      '五行因素': wuxingScore,
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
  double _calculateLunarScore(Lunar lunar, FortuneType type) {
    try {
      double score = 0.7; // 基礎分數
      
      // 考慮節氣影響
      final jieQi = lunar.getJieQi();
      if (jieQi.isNotEmpty) {
        score += 0.1;
      }
      
      // 考慮農曆節日
      final festivals = lunar.getFestivals();
      if (festivals.isNotEmpty) {
        score += 0.1;
      }
      
      // 考慮宜忌
      final yi = lunar.getDayYi();
      final ji = lunar.getDayJi();
      score += (yi.length - ji.length) * 0.02;
      
      // 根據運勢類型調整
      score *= switch (type) {
        FortuneType.daily => 1.0,
        FortuneType.love when festivals.contains('七夕') => 1.5,
        FortuneType.career when lunar.getDay() == 1 => 1.3,
        FortuneType.study when lunar.getDay() == 8 => 1.2,
        _ => 1.0,
      };

      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算農曆分數失敗: $e');
      return 0.6;
    }
  }

  /// 計算五行分數
  double _calculateWuxingScore(Lunar lunar, FortuneType type) {
    try {
      final dayWuxing = lunar.getDayWuXing();
      final timeWuxing = lunar.getTimeWuXing();
      
      // 計算五行相生相剋
      double score = 0.7;
      if (_isWuxingBeneficial(dayWuxing, timeWuxing)) {
        score += 0.2;
      } else if (_isWuxingHarmful(dayWuxing, timeWuxing)) {
        score -= 0.2;
      }
      
      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算五行分數失敗: $e');
      return 0.6;
    }
  }

  bool _isWuxingBeneficial(String wuxing1, String wuxing2) {
    const beneficial = {
      '木': '火',
      '火': '土',
      '土': '金',
      '金': '水',
      '水': '木',
    };
    return beneficial[wuxing1] == wuxing2;
  }

  bool _isWuxingHarmful(String wuxing1, String wuxing2) {
    const harmful = {
      '木': '金',
      '金': '火',
      '火': '水',
      '水': '土',
      '土': '木',
    };
    return harmful[wuxing1] == wuxing2;
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

  /// 生成運勢建議
  List<String> _generateSuggestions({
    required Lunar lunar,
    required FortuneType type,
    required double score,
    required Map<String, double> factors,
  }) {
    final suggestions = <String>[];
    
    // 添加基本運勢建議
    suggestions.add(_getOverallSuggestion(score));
    
    // 添加宜忌建議
    final yi = lunar.getDayYi();
    final ji = lunar.getDayJi();
    if (yi.isNotEmpty) {
      suggestions.add('今日宜：${yi.take(3).join("、")}');
    }
    if (ji.isNotEmpty) {
      suggestions.add('今日忌：${ji.take(3).join("、")}');
    }
    
    // 添加吉神方位
    final positions = lunar.getDayPositions();
    if (positions.isNotEmpty) {
      suggestions.add('吉神方位：${positions.take(2).join("、")}');
    }
    
    // 添加特定類型建議
    suggestions.addAll(_getTypeSpecificSuggestions(type, lunar));
    
    return suggestions;
  }

  /// 獲取總體建議
  String _getOverallSuggestion(double score) {
    if (score >= 0.8) {
      return '今日運勢極佳，適合大展拳腳';
    } else if (score >= 0.7) {
      return '運勢不錯，可以嘗試新事物';
    } else if (score >= 0.6) {
      return '運勢平平，宜按部就班行事';
    } else if (score >= 0.5) {
      return '運勢欠佳，建議謹慎行事';
    } else {
      return '今日運勢不佳，宜靜養休息';
    }
  }

  /// 獲取特定類型建議
  List<String> _getTypeSpecificSuggestions(FortuneType type, Lunar lunar) {
    final suggestions = <String>[];
    
    switch (type) {
      case FortuneType.study:
        if (lunar.getDayWuXing() == '金') {
          suggestions.add('今日思維敏捷，適合學習新知識');
        }
        suggestions.add('建議在${lunar.getDayPositions().firstOrNull ?? "書房"}方位學習');
        
      case FortuneType.career:
        if (lunar.getDayGan().contains('甲')) {
          suggestions.add('今日適合開展新項目');
        }
        suggestions.add('事業有貴人相助，把握機會');
        
      case FortuneType.love:
        if (lunar.getDayZhi().contains('卯')) {
          suggestions.add('桃花運旺盛，適合表達心意');
        }
        suggestions.add('留意${lunar.getDayChongDesc()}方向的緣分');
        
      case FortuneType.wealth:
        final pengZuGan = lunar.getDayPengZuGan();
        suggestions.add('財運提示：$pengZuGan');
        suggestions.add('投資建議：謹慎為上');
        
      case FortuneType.health:
        suggestions.add('今日養生要點：${lunar.getDayTaishen()}');
        suggestions.add('注意保健：${lunar.getDaySha()}');
        
      case FortuneType.travel:
        suggestions.add('出行建議：往${lunar.getDayPositions().firstOrNull ?? "東"}方向');
        suggestions.add('避開：${lunar.getDayChongDesc()}');
        
      case FortuneType.social:
        suggestions.add('人際運勢：${lunar.getDayXiu()}');
        suggestions.add('貴人方位：${lunar.getDayPositions().firstOrNull}');
        
      case FortuneType.creativity:
        if (lunar.getDayWuXing() == '火') {
          suggestions.add('今日靈感充沛，適合創作');
        }
        suggestions.add('創意提示：保持開放心態');
        
      case FortuneType.daily:
        suggestions.add('今日吉時：${lunar.getTimeZhi()}');
        suggestions.add('開運建議：${lunar.getDayYi().firstOrNull ?? "平和心態"}');
    }
    
    return suggestions;
  }
} 