import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_lunar_calendar/chinese_lunar_calendar.dart';
import '../models/lunar_date.dart';

final lunarServiceProvider = Provider<LunarService>((ref) => LunarService());

class LunarService {
  final _lunar = ChineseLunarCalendar();

  /// 將公曆日期轉換為農曆日期
  LunarDate solarToLunar(DateTime date) {
    final lunarDate = _lunar.convertSolarToLunar(
      date.year,
      date.month,
      date.day,
    );
    
    return LunarDate(
      year: lunarDate.year,
      month: lunarDate.month,
      day: lunarDate.day,
      isLeapMonth: lunarDate.isLeapMonth,
      heavenlyStem: lunarDate.heavenlyStem,
      earthlyBranch: lunarDate.earthlyBranch,
      zodiac: lunarDate.zodiac,
      solarTerm: lunarDate.solarTerm,
      festival: _getLunarFestival(lunarDate),
    );
  }

  /// 將農曆日期轉換為公曆日期
  DateTime lunarToSolar(int year, int month, int day, {bool isLeap = false}) {
    final solarDate = _lunar.convertLunarToSolar(
      year,
      month,
      day,
      isLeapMonth: isLeap,
    );
    return DateTime(solarDate.year, solarDate.month, solarDate.day);
  }

  /// 獲取當月的農曆日期列表
  List<LunarDate> getMonthLunarDates(int year, int month) {
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
  int? getLeapMonth(int year) {
    final leapMonth = _lunar.getLeapMonth(year);
    return leapMonth > 0 ? leapMonth : null;
  }

  /// 獲取指定農曆月份的天數
  int getDaysInLunarMonth(int year, int month, {bool isLeap = false}) {
    return _lunar.getDaysInLunarMonth(year, month, isLeapMonth: isLeap);
  }

  /// 檢查指定年月日是否合法
  bool isValidLunarDate(int year, int month, int day, {bool isLeap = false}) {
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    
    try {
      final daysInMonth = getDaysInLunarMonth(year, month, isLeap: isLeap);
      if (day < 1 || day > daysInMonth) return false;
      
      if (isLeap && getLeapMonth(year) != month) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 獲取農曆節日
  String? _getLunarFestival(LunarDate lunarDate) {
    final festivals = {
      // 春節
      '1-1': '春節',
      // 元宵
      '1-15': '元宵節',
      // 端午
      '5-5': '端午節',
      // 七夕
      '7-7': '七夕節',
      // 中元
      '7-15': '中元節',
      // 中秋
      '8-15': '中秋節',
      // 重陽
      '9-9': '重陽節',
      // 臘八
      '12-8': '臘八節',
      // 除夕（需要特殊處理）
      '12-30': '除夕',
    };
    
    final key = '${lunarDate.month}-${lunarDate.day}';
    return festivals[key];
  }

  /// 獲取下一個節氣
  (String name, DateTime date) getNextSolarTerm(DateTime date) {
    final nextTerm = _lunar.getNextSolarTerm(date);
    return (nextTerm.name, nextTerm.date);
  }

  /// 獲取當前節氣
  (String name, DateTime date) getCurrentSolarTerm(DateTime date) {
    final currentTerm = _lunar.getCurrentSolarTerm(date);
    return (currentTerm.name, currentTerm.date);
  }

  /// 獲取今日時辰
  String getCurrentTimeZhi(DateTime date) {
    return _lunar.getTimeZhi(date);
  }

  /// 獲取八字
  (String year, String month, String day, String time) getBaZi(DateTime date) {
    final baZi = _lunar.getBaZi(date);
    return (
      baZi.yearGanZhi,
      baZi.monthGanZhi,
      baZi.dayGanZhi,
      baZi.timeGanZhi,
    );
  }
} 