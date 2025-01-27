import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../models/fortune_type.dart';
import 'astronomical_service.dart';

/// 時間因素計算服務
final timeFactorServiceProvider = Provider<TimeFactorService>((ref) {
  final astronomicalService = ref.watch(astronomicalServiceProvider);
  return TimeFactorService(astronomicalService);
});

/// 時間因素服務類，用於計算各種時間因素對運勢的影響
class TimeFactorService {
  final _logger = Logger('TimeFactorService');
  final AstronomicalService _astronomicalService;

  TimeFactorService(this._astronomicalService);

  /// 基礎權重配置
  static const _baseWeights = {
    'solarTerm': 0.3,    // 節氣權重
    'weekday': 0.2,      // 星期權重
    'lunarDay': 0.15,    // 農曆日期權重
    'hour': 0.15,        // 時辰權重
    'moonPhase': 0.1,    // 月相權重
    'season': 0.1,       // 季節權重
  };

  /// 節氣影響力
  static const Map<String, double> _solarTermEffects = {
    '立春': 0.8, '雨水': 0.6, '驚蟄': 0.7, '春分': 0.9,
    '清明': 0.8, '穀雨': 0.6, '立夏': 0.8, '小滿': 0.6,
    '芒種': 0.7, '夏至': 0.9, '小暑': 0.7, '大暑': 0.8,
    '立秋': 0.8, '處暑': 0.6, '白露': 0.7, '秋分': 0.9,
    '寒露': 0.7, '霜降': 0.8, '立冬': 0.8, '小雪': 0.6,
    '大雪': 0.7, '冬至': 0.9, '小寒': 0.7, '大寒': 0.8,
  };

  // 時辰影響力
  static const Map<int, double> _hourlyEffects = {
    0: 0.6,  // 子時 (23:00-1:00)
    1: 0.5,  // 丑時 (1:00-3:00)
    2: 0.4,  // 寅時 (3:00-5:00)
    3: 0.7,  // 卯時 (5:00-7:00)
    4: 0.9,  // 辰時 (7:00-9:00)
    5: 0.8,  // 巳時 (9:00-11:00)
    6: 0.7,  // 午時 (11:00-13:00)
    7: 0.6,  // 未時 (13:00-15:00)
    8: 0.7,  // 申時 (15:00-17:00)
    9: 0.8,  // 酉時 (17:00-19:00)
    10: 0.7, // 戌時 (19:00-21:00)
    11: 0.6, // 亥時 (21:00-23:00)
  };

  // 月相影響力
  static const Map<String, double> _moonPhaseEffects = {
    'newMoon': 0.9,      // 新月
    'waxingCrescent': 0.7, // 眉月
    'firstQuarter': 0.8,   // 上弦月
    'waxingGibbous': 0.7,  // 盈凸月
    'fullMoon': 0.9,       // 滿月
    'waningGibbous': 0.7,  // 虧凸月
    'lastQuarter': 0.8,    // 下弦月
    'waningCrescent': 0.7, // 殘月
  };

  /// 計算時間因素分數
  /// 
  /// [type] 運勢類型
  /// [date] 指定日期，默認為當前日期
  /// 返回一個 0.0 到 1.0 之間的分數
  double calculateTimeFactorScore(FortuneType type, [DateTime? date]) {
    try {
      date ??= DateTime.now();
      final weights = _getAdjustedWeights(type);
      
      // 計算各個時間因素的分數
      final solarTermScore = _calculateSolarTermScore(date);
      final weekdayScore = _calculateWeekdayScore(date, type);
      final lunarDayScore = _calculateLunarDayScore(date);
      final hourScore = _calculateHourScore(date, type);
      final moonPhaseScore = _calculateMoonPhaseScore(date, type);
      final seasonScore = _calculateSeasonScore(date, type);
      
      // 計算加權總分
      final score = solarTermScore * weights['solarTerm']! +
                   weekdayScore * weights['weekday']! +
                   lunarDayScore * weights['lunarDay']! +
                   hourScore * weights['hour']! +
                   moonPhaseScore * weights['moonPhase']! +
                   seasonScore * weights['season']!;
      
      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算時間因素分數失敗: $e');
      return 0.5; // 返回中等分數作為默認值
    }
  }

  /// 根據運勢類型調整權重
  Map<String, double> _getAdjustedWeights(FortuneType type) {
    final weights = Map<String, double>.from(_baseWeights);
    
    switch (type) {
      case FortuneType.study:
        weights['weekday'] = 0.3;
        weights['hour'] = 0.25;
        weights['solarTerm'] = 0.2;
        weights['lunarDay'] = 0.1;
        weights['moonPhase'] = 0.1;
        weights['season'] = 0.05;
      case FortuneType.career:
        weights['weekday'] = 0.3;
        weights['solarTerm'] = 0.25;
        weights['hour'] = 0.2;
        weights['lunarDay'] = 0.1;
        weights['moonPhase'] = 0.1;
        weights['season'] = 0.05;
      case FortuneType.love:
        weights['moonPhase'] = 0.3;
        weights['solarTerm'] = 0.2;
        weights['lunarDay'] = 0.2;
        weights['hour'] = 0.15;
        weights['weekday'] = 0.1;
        weights['season'] = 0.05;
      default:
        // 使用默認權重
        break;
    }
    
    return weights;
  }

  /// 計算節氣分數
  double _calculateSolarTermScore(DateTime date) {
    try {
      final (name, termDate) = _astronomicalService.getCurrentSolarTerm();
      final nextTerm = _astronomicalService.getNextSolarTerm(date);
      
      // 計算距離下一個節氣的天數
      final daysToNext = nextTerm.date.difference(date).inDays;
      
      // 如果是節氣當天，給予最高分
      if (date.year == termDate.year && 
          date.month == termDate.month && 
          date.day == termDate.day) {
        return 1.0;
      }
      
      // 根據距離下一個節氣的天數計算分數
      return 1.0 - (daysToNext / 15.0).clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算節氣分數失敗: $e');
      return 0.5;
    }
  }

  /// 計算星期分數
  double _calculateWeekdayScore(DateTime date, FortuneType type) {
    final weekday = date.weekday; // 1-7，1 表示星期一
    
    switch (type) {
      case FortuneType.study:
        // 週一到週五較好
        return weekday <= 5 ? 0.8 + (6 - weekday) * 0.04 : 0.4;
      case FortuneType.career:
        // 週二到週四最好
        return switch (weekday) {
          2 || 3 || 4 => 0.9,
          1 || 5 => 0.7,
          _ => 0.4,
        };
      case FortuneType.love:
        // 週末較好
        return weekday >= 6 ? 0.9 : 0.6;
      default:
        // 其他類型使用通用評分
        return weekday <= 5 ? 0.7 : 0.8;
    }
  }

  /// 計算農曆日期分數
  double _calculateLunarDayScore(DateTime date) {
    try {
      final (_, month, day) = _astronomicalService.getLunarDate(date);
      
      // 初一、十五、初八、二十三等傳統吉日給予較高分數
      if (day == 1 || day == 15) return 1.0;
      if (day == 8 || day == 23) return 0.9;
      if (day == 3 || day == 7 || day == 13 || day == 27) return 0.8;
      
      // 農曆月初和月末給予較低分數
      if (day <= 2 || day >= 29) return 0.6;
      
      // 其他日期給予中等分數
      return 0.7;
    } catch (e) {
      _logger.warning('計算農曆日期分數失敗: $e');
      return 0.5;
    }
  }

  /// 計算時辰分數
  double _calculateHourScore(DateTime date, FortuneType type) {
    final hour = date.hour;
    
    switch (type) {
      case FortuneType.study:
        // 早上和下午較好
        if (hour >= 8 && hour <= 11) return 0.9;
        if (hour >= 14 && hour <= 17) return 0.8;
        if (hour >= 6 && hour <= 7) return 0.7;
        return 0.5;
      case FortuneType.career:
        // 上午較好
        if (hour >= 9 && hour <= 11) return 0.9;
        if (hour >= 14 && hour <= 16) return 0.8;
        if (hour >= 7 && hour <= 8) return 0.7;
        return 0.5;
      case FortuneType.love:
        // 傍晚和晚上較好
        if (hour >= 19 && hour <= 22) return 0.9;
        if (hour >= 16 && hour <= 18) return 0.8;
        return 0.6;
      default:
        // 其他類型使用通用評分
        if (hour >= 8 && hour <= 17) return 0.8;
        if (hour >= 6 && hour <= 7 || hour >= 18 && hour <= 22) return 0.7;
        return 0.5;
    }
  }

  /// 計算月相分數
  double _calculateMoonPhaseScore(DateTime date, FortuneType type) {
    try {
      final moonPhase = _astronomicalService.getMoonPhase(date);
      
      switch (type) {
        case FortuneType.love:
          // 滿月時分數最高
          return 1.0 - (0.5 - (moonPhase - 0.5).abs()) * 2;
        case FortuneType.study:
          // 新月到上弦月較好
          return moonPhase <= 0.5 ? 1.0 - moonPhase : 0.5;
        default:
          // 其他類型使用通用評分
          return 0.7 + moonPhase * 0.3;
      }
    } catch (e) {
      _logger.warning('計算月相分數失敗: $e');
      return 0.5;
    }
  }

  /// 計算季節分數
  double _calculateSeasonScore(DateTime date, FortuneType type) {
    final month = date.month;
    
    switch (type) {
      case FortuneType.study:
        // 春秋兩季較好
        return switch (month) {
          3 || 4 || 5 || 9 || 10 || 11 => 0.9, // 春秋
          6 || 7 || 8 => 0.6,                  // 夏
          _ => 0.7,                            // 冬
        };
      case FortuneType.career:
        // 春季和秋季初較好
        return switch (month) {
          3 || 4 || 9 => 0.9,    // 春季初和秋季初
          5 || 10 => 0.8,        // 春季末和秋季中
          6 || 7 || 8 => 0.7,    // 夏季
          _ => 0.6,              // 冬季
        };
      case FortuneType.love:
        // 春季和秋季較好
        return switch (month) {
          3 || 4 || 5 || 9 || 10 || 11 => 0.9, // 春秋
          6 || 7 || 8 => 0.8,                  // 夏
          _ => 0.7,                            // 冬
        };
      default:
        // 其他類型使用通用評分
        return switch (month) {
          3 || 4 || 5 || 9 || 10 || 11 => 0.8, // 春秋
          6 || 7 || 8 => 0.7,                  // 夏
          _ => 0.6,                            // 冬
        };
    }
  }

  /// 檢查是否為特殊日期
  /// 
  /// 返回一個布爾值，表示指定日期是否為特殊日期（如節日）
  bool isSpecialDate(DateTime date) {
    try {
      // 檢查是否為農曆節日
      if (_astronomicalService.isLunarFestival(date)) {
        return true;
      }
      
      // 檢查是否為節氣
      final (_, termDate) = _astronomicalService.getCurrentSolarTerm();
      if (date.year == termDate.year && 
          date.month == termDate.month && 
          date.day == termDate.day) {
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.warning('檢查特殊日期失敗: $e');
      return false;
    }
  }
} 