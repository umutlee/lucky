import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_type.dart';
import 'lunar_service.dart';
import 'logger_service.dart';

/// 時間因素計算服務
final timeFactorServiceProvider = Provider<TimeFactorService>((ref) {
  final lunarService = ref.watch(lunarServiceProvider);
  final logger = ref.watch(loggerServiceProvider);
  return TimeFactorService(lunarService, logger);
});

/// 時間因素服務類，用於計算各種時間因素對運勢的影響
class TimeFactorService {
  final LunarService _lunarService;
  final LoggerService _logger;

  TimeFactorService(this._lunarService, this._logger);

  /// 計算時間因素分數
  /// 
  /// [date] 要計算的日期
  /// [type] 運勢類型
  /// 返回一個0-1之間的分數，表示該時間點的吉利程度
  double calculateTimeScore(DateTime date, FortuneType type) {
    try {
      // 基礎分數權重
      const weights = {
        'weekday': 0.2,    // 星期幾
        'lunar': 0.3,      // 農曆日期
        'hour': 0.2,       // 時辰
        'season': 0.2,     // 季節
        'special': 0.1,    // 特殊日期
      };
      
      // 計算各項分數
      final weekdayScore = _calculateWeekdayScore(date, type);
      final lunarScore = _calculateLunarDayScore(date);
      final hourScore = _calculateHourScore(date, type);
      final seasonScore = _calculateSeasonScore(date, type);
      final specialScore = isSpecialDate(date) ? 1.0 : 0.7;
      
      // 計算加權總分
      final totalScore = 
        weekdayScore * weights['weekday']! +
        lunarScore * weights['lunar']! +
        hourScore * weights['hour']! +
        seasonScore * weights['season']! +
        specialScore * weights['special']!;
      
      return totalScore;
    } catch (e) {
      _logger.error('計算時間因素分數失敗', e);
      return 0.5; // 返回中等分數作為默認值
    }
  }

  /// 計算星期幾的分數
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
      final lunarDate = _lunarService.solarToLunar(date);
      
      // 初一、十五、初八、二十三等傳統吉日給予較高分數
      if (lunarDate.day == 1 || lunarDate.day == 15) return 1.0;
      if (lunarDate.day == 8 || lunarDate.day == 23) return 0.9;
      if (lunarDate.day == 3 || lunarDate.day == 7 || 
          lunarDate.day == 13 || lunarDate.day == 27) return 0.8;
      
      // 農曆月初和月末給予較低分數
      if (lunarDate.day <= 2 || lunarDate.day >= 29) return 0.6;
      
      // 其他日期給予中等分數
      return 0.7;
    } catch (e) {
      _logger.warning('計算農曆日期分數失敗: $e');
      return 0.5;
    }
  }

  /// 計算時辰分數
  double _calculateHourScore(DateTime date, FortuneType type) {
    try {
      final timeZhi = _lunarService.getCurrentTimeZhi(date);
      
      // 根據不同運勢類型，不同時辰有不同的吉利程度
      switch (type) {
        case FortuneType.study:
          // 寅時（3-5點）、卯時（5-7點）、辰時（7-9點）最適合學習
          return switch (timeZhi) {
            '寅' || '卯' || '辰' => 0.9,
            '巳' || '午' || '未' => 0.7,
            '申' || '酉' || '戌' => 0.6,
            _ => 0.4,
          };
        case FortuneType.career:
          // 巳時（9-11點）、午時（11-13點）、未時（13-15點）最適合工作
          return switch (timeZhi) {
            '巳' || '午' || '未' => 0.9,
            '辰' || '申' => 0.8,
            '寅' || '卯' || '酉' || '戌' => 0.6,
            _ => 0.4,
          };
        case FortuneType.love:
          // 酉時（17-19點）、戌時（19-21點）、亥時（21-23點）最適合約會
          return switch (timeZhi) {
            '酉' || '戌' || '亥' => 0.9,
            '午' || '未' || '申' => 0.7,
            _ => 0.5,
          };
        default:
          // 其他類型使用通用評分
          return switch (timeZhi) {
            '寅' || '卯' || '辰' => 0.8,
            '巳' || '午' || '未' => 0.8,
            '申' || '酉' || '戌' => 0.7,
            _ => 0.6,
          };
      }
    } catch (e) {
      _logger.warning('計算時辰分數失敗: $e');
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
  bool isSpecialDate(DateTime date) {
    try {
      final lunarDate = _lunarService.solarToLunar(date);
      
      // 檢查是否為農曆節日
      if (lunarDate.festival != null) {
        return true;
      }
      
      // 檢查是否為節氣
      if (lunarDate.solarTerm != null) {
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.warning('檢查特殊日期失敗: $e');
      return false;
    }
  }
} 