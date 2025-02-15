import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import '../models/calendar_day.dart';
import '../utils/logger.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  final logger = Logger('CalendarService');
  return CalendarService(logger);
});

class CalendarService {
  final Logger _logger;

  CalendarService(this._logger);

  /// 獲取指定月份的日曆數據
  List<CalendarDay> getMonthCalendar(int year, int month) {
    try {
      final days = <CalendarDay>[];
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      
      // 獲取月初的星期幾（0是星期日）
      final firstWeekday = firstDay.weekday;
      
      // 添加上個月的日期
      if (firstWeekday > 0) {
        final prevMonth = DateTime(year, month, 0);
        for (var i = firstWeekday - 1; i >= 0; i--) {
          final date = DateTime(year, month - 1, prevMonth.day - i);
          days.add(_createCalendarDay(date, isCurrentMonth: false));
        }
      }
      
      // 添加當月的日期
      for (var i = 1; i <= lastDay.day; i++) {
        final date = DateTime(year, month, i);
        days.add(_createCalendarDay(date, isCurrentMonth: true));
      }
      
      // 添加下個月的日期
      final remainingDays = 42 - days.length; // 保證總是顯示6週
      for (var i = 1; i <= remainingDays; i++) {
        final date = DateTime(year, month + 1, i);
        days.add(_createCalendarDay(date, isCurrentMonth: false));
      }
      
      return days;
    } catch (e) {
      _logger.error('獲取月曆數據失敗', e);
      return [];
    }
  }

  /// 創建日曆天對象
  CalendarDay _createCalendarDay(DateTime date, {required bool isCurrentMonth}) {
    try {
      final lunar = Lunar.fromDate(date);
      
      return CalendarDay(
        date: date,
        lunarDay: lunar.getDayInChinese(),
        solarTerm: lunar.getJieQi(),
        festival: _getFestival(lunar),
        isCurrentMonth: isCurrentMonth,
        isWeekend: date.weekday >= 6,
        isHoliday: _isHoliday(lunar),
        dayYi: lunar.getDayYi(),
        dayJi: lunar.getDayJi(),
        timeZhi: lunar.getTimeZhi(),
        wuXing: lunar.getDayWuXing(),
        positions: lunar.getDayPositions(),
        ganZhi: '${lunar.getDayGan()}${lunar.getDayZhi()}',
      );
    } catch (e) {
      _logger.error('創建日曆天對象失敗', e);
      return CalendarDay(
        date: date,
        lunarDay: '',
        isCurrentMonth: isCurrentMonth,
        isWeekend: date.weekday >= 6,
        isHoliday: false,
        dayYi: [],
        dayJi: [],
        positions: [],
      );
    }
  }

  /// 獲取節日信息
  String? _getFestival(Lunar lunar) {
    final festivals = lunar.getFestivals();
    if (festivals.isNotEmpty) {
      return festivals.join('、');
    }
    return null;
  }

  /// 檢查是否為假日
  bool _isHoliday(Lunar lunar) {
    // 週末
    if (lunar.getSolar().getWeek() >= 6) {
      return true;
    }
    
    // 農曆節日
    final festivals = lunar.getFestivals();
    if (festivals.isNotEmpty) {
      return true;
    }
    
    // 節氣
    final jieQi = lunar.getJieQi();
    if (jieQi.isNotEmpty) {
      return true;
    }
    
    return false;
  }

  /// 獲取當日運勢提示
  ({
    String summary,
    List<String> yi,
    List<String> ji,
    List<String> positions,
  }) getDayFortune(DateTime date) {
    try {
      final lunar = Lunar.fromDate(date);
      
      return (
        summary: _getDaySummary(lunar),
        yi: lunar.getDayYi(),
        ji: lunar.getDayJi(),
        positions: lunar.getDayPositions(),
      );
    } catch (e) {
      _logger.error('獲取當日運勢失敗', e);
      return (
        summary: '運勢平平',
        yi: [],
        ji: [],
        positions: [],
      );
    }
  }

  /// 獲取當日運勢概述
  String _getDaySummary(Lunar lunar) {
    final dayGan = lunar.getDayGan();
    final dayZhi = lunar.getDayZhi();
    final wuXing = lunar.getDayWuXing();
    
    // 根據天干地支和五行判斷
    if (dayGan.contains('甲') || dayGan.contains('丙')) {
      return '今日大吉，適合開展新事物';
    }
    if (dayZhi.contains('寅') || dayZhi.contains('午')) {
      return '運勢上升，把握機會';
    }
    if (wuXing == '金' || wuXing == '火') {
      return '吉星高照，諸事順遂';
    }
    
    return '運勢平穩，按部就班';
  }

  /// 獲取月運勢概覽
  Map<DateTime, String> getMonthFortune(int year, int month) {
    try {
      final result = <DateTime, String>{};
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      
      for (var date = firstDay;
           date.isBefore(lastDay.add(const Duration(days: 1)));
           date = date.add(const Duration(days: 1))) {
        final lunar = Lunar.fromDate(date);
        result[date] = _getDaySummary(lunar);
      }
      
      return result;
    } catch (e) {
      _logger.error('獲取月運勢概覽失敗', e);
      return {};
    }
  }

  /// 獲取節氣信息
  List<(String name, DateTime date)> getSolarTerms(int year, int month) {
    try {
      final terms = <(String name, DateTime date)>[];
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      
      for (var date = firstDay;
           date.isBefore(lastDay.add(const Duration(days: 1)));
           date = date.add(const Duration(days: 1))) {
        final lunar = Lunar.fromDate(date);
        final jieQi = lunar.getJieQi();
        if (jieQi.isNotEmpty) {
          terms.add((jieQi, date));
        }
      }
      
      return terms;
    } catch (e) {
      _logger.error('獲取節氣信息失敗', e);
      return [];
    }
  }

  /// 獲取月相信息
  List<(String phase, DateTime date)> getMoonPhases(int year, int month) {
    try {
      final phases = <(String phase, DateTime date)>[];
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      
      for (var date = firstDay;
           date.isBefore(lastDay.add(const Duration(days: 1)));
           date = date.add(const Duration(days: 1))) {
        final lunar = Lunar.fromDate(date);
        if (lunar.getDay() == 1) {
          phases.add(('朔', date));
        } else if (lunar.getDay() == 15) {
          phases.add(('望', date));
        }
      }
      
      return phases;
    } catch (e) {
      _logger.error('獲取月相信息失敗', e);
      return [];
    }
  }
} 