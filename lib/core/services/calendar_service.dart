import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/calendar/Lunar.dart' as lunar_lib;
import '../models/calendar_day.dart';
import '../utils/logger.dart';
import '../models/lunar_date.dart';
import '../models/solar_term.dart';
import '../models/daily_activities.dart';

/// 日曆服務提供者
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

/// 日曆服務
class CalendarService {
  final Logger _logger = Logger('CalendarService');

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
      final lunar = lunar_lib.Lunar.fromDate(date);
      
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
        timeZhi: [lunar.getTimeZhi()],
        wuXing: _getWuXing(lunar),
        positions: _getPositions(lunar),
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
  String? _getFestival(lunar_lib.Lunar lunar) {
    final festivals = lunar.getFestivals();
    if (festivals.isNotEmpty) {
      return festivals.join('、');
    }
    return null;
  }

  /// 檢查是否為假日
  bool _isHoliday(lunar_lib.Lunar lunar) {
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
      final lunar = lunar_lib.Lunar.fromDate(date);
      
      return (
        summary: _getDaySummary(lunar),
        yi: lunar.getDayYi(),
        ji: lunar.getDayJi(),
        positions: _getPositions(lunar),
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
  String _getDaySummary(lunar_lib.Lunar lunar) {
    final dayGan = lunar.getDayGan();
    final dayZhi = lunar.getDayZhi();
    final wuXing = _getWuXing(lunar);
    
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
        final lunar = lunar_lib.Lunar.fromDate(date);
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
        final lunar = lunar_lib.Lunar.fromDate(date);
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
        final lunar = lunar_lib.Lunar.fromDate(date);
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

  /// 獲取農曆日期
  Future<LunarDate> getLunarDate(DateTime date) async {
    try {
      final lunar = lunar_lib.Lunar.fromDate(date);
      
      return LunarDate(
        heavenlyStem: lunar.getYearGan(),
        earthlyBranch: lunar.getYearZhi(),
        dayZhi: lunar.getDayZhi(),
        timeZhi: lunar.getTimeZhi(),
        wuXing: _getWuXing(lunar),
        isLeapMonth: lunar.getMonth() != lunar.getMonthInGanZhi(),
        lunarDay: lunar.getDayInChinese(),
        solarTerm: lunar.getJieQi(),
      );
    } catch (e, stack) {
      _logger.error('獲取農曆日期失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取節氣
  Future<SolarTerm> getSolarTerm(DateTime date) async {
    try {
      final lunar = lunar_lib.Lunar.fromDate(date);
      final jieQi = lunar.getJieQi();
      
      return SolarTerm(
        name: jieQi,
        date: date,
      );
    } catch (e, stack) {
      _logger.error('獲取節氣失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取每日宜忌
  Future<DailyActivities> getDailyActivities(DateTime date) async {
    try {
      final lunar = lunar_lib.Lunar.fromDate(date);
      
      return DailyActivities(
        goodActivities: lunar.getDayYi(),
        badActivities: lunar.getDayJi(),
      );
    } catch (e, stack) {
      _logger.error('獲取每日宜忌失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取吉時
  Future<List<String>> getLuckyHours(DateTime date) async {
    try {
      final lunar = lunar_lib.Lunar.fromDate(date);
      final timeZhi = lunar.getTimeZhi();
      
      // 根據時柱判斷吉時
      final luckyHours = <String>[];
      if (timeZhi.contains('子')) luckyHours.add('23:00-1:00');
      if (timeZhi.contains('寅')) luckyHours.add('3:00-5:00');
      if (timeZhi.contains('辰')) luckyHours.add('7:00-9:00');
      if (timeZhi.contains('午')) luckyHours.add('11:00-13:00');
      if (timeZhi.contains('申')) luckyHours.add('15:00-17:00');
      if (timeZhi.contains('戌')) luckyHours.add('19:00-21:00');
      
      return luckyHours;
    } catch (e, stack) {
      _logger.error('獲取吉時失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取五行
  String _getWuXing(lunar_lib.Lunar lunar) {
    final dayGan = lunar.getDayGan();
    
    switch (dayGan) {
      case '甲':
      case '乙':
        return '木';
      case '丙':
      case '丁':
        return '火';
      case '戊':
      case '己':
        return '土';
      case '庚':
      case '辛':
        return '金';
      case '壬':
      case '癸':
        return '水';
      default:
        return '未知';
    }
  }

  /// 獲取方位
  List<String> _getPositions(lunar_lib.Lunar lunar) {
    final dayZhi = lunar.getDayZhi();
    
    switch (dayZhi) {
      case '子':
        return ['北'];
      case '丑':
      case '寅':
        return ['東北'];
      case '卯':
        return ['東'];
      case '辰':
      case '巳':
        return ['東南'];
      case '午':
        return ['南'];
      case '未':
      case '申':
        return ['西南'];
      case '酉':
        return ['西'];
      case '戌':
      case '亥':
        return ['西北'];
      default:
        return [];
    }
  }

  /// 獲取節氣描述
  String _getSolarTermDescription(String jieQi) {
    final descriptions = {
      '立春': '春天開始，萬物復甦',
      '雨水': '降雨增多，氣溫回升',
      '驚蟄': '春雷始鳴，蟄蟲復甦',
      '春分': '晝夜平分，陰陽相等',
      '清明': '天氣清爽明朗',
      '穀雨': '雨生百穀',
      '立夏': '夏天開始，萬物繁茂',
      '小滿': '夏熟作物籽粒飽滿',
      '芒種': '麥類等作物成熟',
      '夏至': '一年中晝最長',
      '小暑': '天氣開始炎熱',
      '大暑': '一年中最熱',
      '立秋': '秋天開始，暑氣漸消',
      '處暑': '暑氣開始消退',
      '白露': '天氣轉涼，露水增多',
      '秋分': '晝夜再次平分',
      '寒露': '露水將寒',
      '霜降': '開始降霜',
      '立冬': '冬天開始，萬物蟄伏',
      '小雪': '開始降雪',
      '大雪': '降雪量增多',
      '冬至': '一年中晝最短',
      '小寒': '天氣寒冷',
      '大寒': '一年中最冷',
    };
    return descriptions[jieQi] ?? '節氣變化';
  }

  /// 獲取節氣五行
  String _getSolarTermElement(String jieQi) {
    final elements = {
      '立春': '木',
      '雨水': '木',
      '驚蟄': '木',
      '春分': '木',
      '清明': '木',
      '穀雨': '木',
      '立夏': '火',
      '小滿': '火',
      '芒種': '火',
      '夏至': '火',
      '小暑': '火',
      '大暑': '火',
      '立秋': '金',
      '處暑': '金',
      '白露': '金',
      '秋分': '金',
      '寒露': '金',
      '霜降': '金',
      '立冬': '水',
      '小雪': '水',
      '大雪': '水',
      '冬至': '水',
      '小寒': '水',
      '大寒': '水',
    };
    return elements[jieQi] ?? '木';
  }
} 