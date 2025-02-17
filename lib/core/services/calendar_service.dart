import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import '../models/calendar_day.dart';
import '../utils/logger.dart';
import '../models/lunar_date.dart';
import '../models/solar_term.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  final logger = Logger('CalendarService');
  return CalendarService(logger);
});

class DailyActivities {
  final List<String> good;
  final List<String> bad;

  DailyActivities({
    required this.good,
    required this.bad,
  });
}

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

  Future<LunarDate> getLunarDate(DateTime date) async {
    try {
      final lunar = Lunar.fromDate(date);
      return LunarDate(
        heavenlyStem: lunar.getDayGan(),
        earthlyBranch: lunar.getDayZhi(),
        dayZhi: lunar.getDayZhi(),
        timeZhi: lunar.getTimeZhi()[0],
        wuXing: lunar.getDayWuXing(),
        positions: lunar.getDayPositions(),
        year: lunar.getYear(),
        month: lunar.getMonth(),
        day: lunar.getDay(),
        isLeapMonth: lunar.isLeapMonth(),
      );
    } catch (e) {
      _logger.error('獲取農曆日期失敗', e);
      return LunarDate(
        heavenlyStem: '甲',
        earthlyBranch: '子',
        dayZhi: '子',
        timeZhi: '子',
        wuXing: '木',
        positions: ['北'],
        year: date.year,
        month: date.month,
        day: date.day,
        isLeapMonth: false,
      );
    }
  }

  Future<SolarTerm> getSolarTerm(DateTime date) async {
    try {
      final lunar = Lunar.fromDate(date);
      final jieQi = lunar.getJieQi();
      if (jieQi.isNotEmpty) {
        return SolarTerm(
          name: jieQi,
          date: date,
          description: _getSolarTermDescription(jieQi),
          element: _getSolarTermElement(jieQi),
        );
      }
      
      // 如果當天不是節氣，返回最近的一個節氣
      final terms = getSolarTerms(date.year, date.month);
      if (terms.isNotEmpty) {
        final (name, termDate) = terms.first;
        return SolarTerm(
          name: name,
          date: termDate,
          description: _getSolarTermDescription(name),
          element: _getSolarTermElement(name),
        );
      }
      
      return SolarTerm(
        name: '',
        date: date,
        description: '',
        element: '',
      );
    } catch (e) {
      _logger.error('獲取節氣失敗', e);
      return SolarTerm(
        name: '',
        date: date,
        description: '',
        element: '',
      );
    }
  }

  String _getSolarTermDescription(String term) {
    switch (term) {
      case '立春':
        return '春季的開始，萬物復甦的時節';
      case '雨水':
        return '雨量漸增，氣溫回升的時節';
      case '驚蟄':
        return '春雷始鳴，萬物驚醒的時節';
      case '春分':
        return '晝夜平分，春光明媚的時節';
      case '清明':
        return '天氣清爽，萬物生長的時節';
      case '穀雨':
        return '雨生百穀，春耕開始的時節';
      case '立夏':
        return '夏季的開始，萬物繁茂的時節';
      case '小滿':
        return '穀物漸滿，春收開始的時節';
      case '芒種':
        return '麥收種稻，農忙的時節';
      case '夏至':
        return '晝最長，炎熱的時節';
      case '小暑':
        return '暑氣漸增，炎熱的時節';
      case '大暑':
        return '一年中最熱的時節';
      case '立秋':
        return '秋季的開始，暑氣漸消的時節';
      case '處暑':
        return '暑氣漸消，涼爽的時節';
      case '白露':
        return '露水漸多，氣溫轉涼的時節';
      case '秋分':
        return '晝夜平分，秋高氣爽的時節';
      case '寒露':
        return '露水漸寒，氣溫下降的時節';
      case '霜降':
        return '霜始降，氣溫驟降的時節';
      case '立冬':
        return '冬季的開始，萬物蟄伏的時節';
      case '小雪':
        return '雪漸降，天氣寒冷的時節';
      case '大雪':
        return '雪量漸增，嚴寒的時節';
      case '冬至':
        return '晝最短，寒冷的時節';
      case '小寒':
        return '寒氣漸增，嚴寒的時節';
      case '大寒':
        return '一年中最冷的時節';
      default:
        return '';
    }
  }

  String _getSolarTermElement(String term) {
    switch (term) {
      case '立春':
      case '驚蟄':
      case '清明':
        return '木';
      case '立夏':
      case '小滿':
      case '芒種':
        return '火';
      case '立秋':
      case '處暑':
      case '白露':
        return '金';
      case '立冬':
      case '小雪':
      case '大雪':
        return '水';
      case '雨水':
      case '春分':
      case '穀雨':
      case '夏至':
      case '小暑':
      case '大暑':
      case '秋分':
      case '寒露':
      case '霜降':
      case '冬至':
      case '小寒':
      case '大寒':
        return '土';
      default:
        return '';
    }
  }

  Future<DailyActivities> getDailyActivities(DateTime date) async {
    try {
      final lunar = Lunar.fromDate(date);
      return DailyActivities(
        good: lunar.getDayYi(),
        bad: lunar.getDayJi(),
      );
    } catch (e) {
      _logger.error('獲取宜忌失敗', e);
      return DailyActivities(
        good: [],
        bad: [],
      );
    }
  }

  Future<List<String>> getLuckyHours(DateTime date) async {
    try {
      final lunar = Lunar.fromDate(date);
      final luckyHours = <String>[];
      
      // 獲取吉時
      final timeZhi = lunar.getTimeZhi();
      for (var i = 0; i < timeZhi.length; i++) {
        if (timeZhi[i].contains('吉')) {
          final hourName = _getChineseHour(i);
          luckyHours.add(hourName);
        }
      }
      
      return luckyHours;
    } catch (e) {
      _logger.error('獲取吉時失敗', e);
      return [];
    }
  }

  String _getChineseHour(int index) {
    const hours = [
      '子時', '丑時', '寅時', '卯時', '辰時', '巳時',
      '午時', '未時', '申時', '酉時', '戌時', '亥時'
    ];
    return hours[index % 12];
  }
} 