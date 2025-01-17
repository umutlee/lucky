import 'package:lunar/lunar.dart';
import '../models/lunar_date.dart';
import '../../shared/utils/date_converter.dart';

/// 農曆計算服務
class LunarCalculator {
  LunarCalculator._();

  /// 將公曆日期轉換為農曆日期
  static LunarDate solarToLunar(DateTime solarDate) {
    final lunar = Lunar.fromDate(solarDate);
    
    final (heavenlyStem, earthlyBranch) = DateConverter.getStemBranch(lunar.getYear());
    
    return LunarDate(
      year: lunar.getYear(),
      month: lunar.getMonth(),
      day: lunar.getDay(),
      isLeapMonth: lunar.isLeap(),
      heavenlyStem: heavenlyStem,
      earthlyBranch: earthlyBranch,
      zodiac: DateConverter.getZodiac(lunar.getYear()),
      solarTerm: DateConverter.getSolarTerm(solarDate),
      festival: DateConverter.getLunarFestival(LunarDate(
        year: lunar.getYear(),
        month: lunar.getMonth(),
        day: lunar.getDay(),
        isLeapMonth: lunar.isLeap(),
        heavenlyStem: heavenlyStem,
        earthlyBranch: earthlyBranch,
        zodiac: DateConverter.getZodiac(lunar.getYear()),
      )),
    );
  }

  /// 將農曆日期轉換為公曆日期
  static DateTime lunarToSolar(int year, int month, int day, bool isLeapMonth) {
    final lunar = Lunar.fromYmd(year, month, day);
    if (isLeapMonth) {
      lunar.setLeap(true);
    }
    return lunar.getDate();
  }

  /// 獲取當月的農曆日期列表
  static List<LunarDate> getMonthLunarDates(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    final List<LunarDate> dates = [];
    for (var date = firstDay;
         date.isBefore(lastDay.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      dates.add(solarToLunar(date));
    }
    
    return dates;
  }

  /// 獲取當年的閏月（如果有的話）
  static int? getLeapMonth(int year) {
    final lunar = Lunar.fromDate(DateTime(year, 1, 1));
    final leapMonth = lunar.getLeapMonth();
    return leapMonth > 0 ? leapMonth : null;
  }

  /// 獲取指定農曆月份的天數
  static int getDaysInLunarMonth(int year, int month, bool isLeapMonth) {
    final lunar = Lunar.fromYmd(year, month, 1);
    if (isLeapMonth) {
      lunar.setLeap(true);
    }
    return lunar.getDaysInMonth();
  }

  /// 檢查指定年月日是否合法
  static bool isValidLunarDate(int year, int month, int day, bool isLeapMonth) {
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    
    try {
      final daysInMonth = getDaysInLunarMonth(year, month, isLeapMonth);
      if (day < 1 || day > daysInMonth) return false;
      
      if (isLeapMonth && getLeapMonth(year) != month) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }
} 