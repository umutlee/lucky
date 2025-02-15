import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_type.dart';
import 'logger_service.dart';

/// 時間因素計算服務
final timeFactorServiceProvider = Provider<TimeFactorService>((ref) {
  final logger = ref.watch(loggerServiceProvider);
  return TimeFactorService(logger);
});

/// 時間因素服務類，用於計算各種時間因素對運勢的影響
class TimeFactorService {
  final LoggerService _logger;

  TimeFactorService(this._logger);

  /// 計算時間分數
  double calculateTimeScore(DateTime date, FortuneType type) {
    try {
      final hour = date.hour;
      final weekday = date.weekday;
      
      // 基礎時間分數
      var score = _calculateBaseTimeScore(hour);
      
      // 根據場景類型調整分數
      score = _adjustScoreByType(score, type, hour, weekday);
      
      // 確保分數在 0-1 範圍內
      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算時間分數失敗: $e');
      return 0.7;
    }
  }

  /// 計算基礎時間分數
  double _calculateBaseTimeScore(int hour) {
    // 根據一天中的時間段計算基礎分數
    return switch (hour) {
      >= 5 && < 8 => 0.8,   // 早晨
      >= 8 && < 11 => 0.9,  // 上午
      >= 11 && < 14 => 0.7, // 中午
      >= 14 && < 17 => 0.8, // 下午
      >= 17 && < 20 => 0.9, // 傍晚
      >= 20 && < 23 => 0.7, // 晚上
      _ => 0.5,             // 深夜
    };
  }

  /// 根據場景類型調整分數
  double _adjustScoreByType(
    double baseScore,
    FortuneType type,
    int hour,
    int weekday,
  ) {
    var score = baseScore;
    
    switch (type) {
      case FortuneType.study:
        // 學習最佳時間：上午和下午
        if (hour >= 8 && hour < 11 || hour >= 14 && hour < 17) {
          score += 0.1;
        }
        // 週末學習效率可能較低
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          score -= 0.1;
        }
        
      case FortuneType.career:
        // 工作日更適合職場活動
        if (weekday >= DateTime.monday && weekday <= DateTime.friday) {
          score += 0.1;
        }
        // 工作時間更適合
        if (hour >= 9 && hour < 18) {
          score += 0.1;
        }
        
      case FortuneType.love:
        // 傍晚和晚上更適合約會
        if (hour >= 17 && hour < 23) {
          score += 0.2;
        }
        // 週末更適合約會
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          score += 0.1;
        }
        
      case FortuneType.wealth:
        // 股市交易時間
        if (hour >= 9 && hour < 15 &&
            weekday >= DateTime.monday && weekday <= DateTime.friday) {
          score += 0.2;
        }
        
      case FortuneType.health:
        // 運動最佳時間：早晨和傍晚
        if (hour >= 6 && hour < 9 || hour >= 17 && hour < 20) {
          score += 0.2;
        }
        
      case FortuneType.travel:
        // 週末更適合旅遊
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          score += 0.2;
        }
        // 白天更適合出行
        if (hour >= 8 && hour < 18) {
          score += 0.1;
        }
        
      case FortuneType.social:
        // 社交活動適合的時間
        if (hour >= 11 && hour < 14 || hour >= 18 && hour < 22) {
          score += 0.2;
        }
        // 週末社交更自由
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          score += 0.1;
        }
        
      case FortuneType.creativity:
        // 創意靈感時間：早晨和深夜
        if (hour >= 5 && hour < 8 || hour >= 22) {
          score += 0.2;
        }
        
      case FortuneType.daily:
        // 日常活動不受時間影響
        break;
    }
    
    return score;
  }
} 