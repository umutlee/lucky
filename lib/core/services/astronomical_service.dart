import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import 'package:logging/logging.dart';

final astronomicalServiceProvider = Provider<AstronomicalService>((ref) {
  return AstronomicalService();
});

/// 天文計算服務類，用於處理太陽節氣、農曆日期和月相的計算
class AstronomicalService {
  final _logger = Logger('AstronomicalService');

  /// 獲取當前太陽節氣
  /// 
  /// 返回一個包含節氣名稱和日期的元組
  (String name, DateTime date) getCurrentSolarTerm() {
    try {
      final lunar = Lunar.fromDate(DateTime.now());
      final jieQi = lunar.getCurrentJieQi();
      return (jieQi.getName(), jieQi.getSolar().toDate());
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
      final lunar = Lunar.fromDate(date);
      return (lunar.getYear(), lunar.getMonth(), lunar.getDay());
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
      final lunar = Lunar.fromDate(date);
      final day = lunar.getDay();
      // 農曆初一為朔（新月），十五為望（滿月）
      return day <= 15 ? day / 15 : (30 - day) / 15;
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
      final lunar = Lunar.fromDate(date);
      return lunar.getFestivals().isNotEmpty;
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
      final lunar = Lunar.fromDate(date);
      final nextJieQi = lunar.getNextJieQi();
      return (nextJieQi.getName(), nextJieQi.getSolar().toDate());
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
      final startLunar = Lunar.fromDate(start);
      final endLunar = Lunar.fromDate(end);
      
      // 計算農曆天數差
      final startDays = startLunar.getYear() * 365 + startLunar.getMonth() * 30 + startLunar.getDay();
      final endDays = endLunar.getYear() * 365 + endLunar.getMonth() * 30 + endLunar.getDay();
      
      return (endDays - startDays).abs();
    } catch (e) {
      _logger.warning('計算農曆天數差失敗: $e');
      return 0;
    }
  }
} 