import 'package:chinese_lunar_calendar/chinese_lunar_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final astronomicalServiceProvider = Provider<AstronomicalService>((ref) {
  return AstronomicalService();
});

/// 天文計算服務類，用於處理太陽節氣、農曆日期和月相的計算
class AstronomicalService {
  final _logger = Logger('AstronomicalService');
  final _calendar = ChineseLunarCalendar();

  /// 獲取當前太陽節氣
  /// 
  /// 返回一個包含節氣名稱和日期的元組
  (String name, DateTime date) getCurrentSolarTerm() {
    try {
      final now = DateTime.now();
      final term = _calendar.getSolarTerm(now.year, now.month);
      return (term.name, term.date);
    } catch (e) {
      _logger.warning('獲取太陽節氣失敗: $e');
      return ('未知', DateTime.now());
    }
  }

  /// 獲取農曆日期
  /// 
  /// 返回一個包含農曆年、月、日的元組
  (int year, int month, int day) getLunarDate([DateTime? date]) {
    try {
      date ??= DateTime.now();
      final lunar = _calendar.getLunarDate(date);
      return (lunar.year, lunar.month, lunar.day);
    } catch (e) {
      _logger.warning('獲取農曆日期失敗: $e');
      return (0, 0, 0);
    }
  }

  /// 獲取月相
  /// 
  /// 返回一個 0 到 1 之間的數值，表示月亮的圓缺程度
  /// 0 表示新月，0.5 表示上弦或下弦，1 表示滿月
  double getMoonPhase([DateTime? date]) {
    try {
      date ??= DateTime.now();
      return _calendar.getMoonPhase(date);
    } catch (e) {
      _logger.warning('獲取月相失敗: $e');
      return 0.0;
    }
  }

  /// 檢查是否為節日
  /// 
  /// 返回一個布爾值，表示指定日期是否為農曆節日
  bool isLunarFestival([DateTime? date]) {
    try {
      date ??= DateTime.now();
      final lunar = _calendar.getLunarDate(date);
      
      // 農曆新年：正月初一
      if (lunar.month == 1 && lunar.day == 1) return true;
      
      // 元宵節：正月十五
      if (lunar.month == 1 && lunar.day == 15) return true;
      
      // 端午節：五月初五
      if (lunar.month == 5 && lunar.day == 5) return true;
      
      // 中秋節：八月十五
      if (lunar.month == 8 && lunar.day == 15) return true;
      
      // 重陽節：九月初九
      if (lunar.month == 9 && lunar.day == 9) return true;
      
      return false;
    } catch (e) {
      _logger.warning('檢查節日失敗: $e');
      return false;
    }
  }

  /// 獲取下一個節氣的日期
  /// 
  /// 返回一個包含節氣名稱和日期的元組
  (String name, DateTime date) getNextSolarTerm([DateTime? date]) {
    try {
      date ??= DateTime.now();
      final term = _calendar.getNextSolarTerm(date);
      return (term.name, term.date);
    } catch (e) {
      _logger.warning('獲取下一個節氣失敗: $e');
      return ('未知', date ?? DateTime.now());
    }
  }

  /// 計算兩個日期之間的農曆天數差
  /// 
  /// [start] 開始日期
  /// [end] 結束日期
  /// 返回天數差，如果計算失敗則返回 0
  int getLunarDaysBetween(DateTime start, DateTime end) {
    try {
      final startLunar = _calendar.getLunarDate(start);
      final endLunar = _calendar.getLunarDate(end);
      
      // 計算農曆天數差
      final startDays = startLunar.year * 365 + startLunar.month * 30 + startLunar.day;
      final endDays = endLunar.year * 365 + endLunar.month * 30 + endLunar.day;
      
      return (endDays - startDays).abs();
    } catch (e) {
      _logger.warning('計算農曆天數差失敗: $e');
      return 0;
    }
  }
} 