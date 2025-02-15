import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import '../models/lunar_date.dart' as app;
import '../utils/logger.dart';

final lunarServiceProvider = Provider<LunarService>((ref) {
  final logger = Logger('LunarService');
  return LunarService(logger);
});

class LunarService {
  final Logger _logger;

  LunarService(this._logger);

  /// 將公曆日期轉換為農曆日期
  app.LunarDate solarToLunar(DateTime date) {
    try {
      final lunar = Lunar.fromDate(date);
      return app.LunarDate(
        year: lunar.getYear(),
        month: lunar.getMonth(),
        day: lunar.getDay(),
        isLeapMonth: lunar.isLeap(),
        heavenlyStem: lunar.getYearGan(),
        earthlyBranch: lunar.getYearZhi(),
        zodiac: lunar.getYearShengXiao(),
        solarTerm: lunar.getJieQi(),
        festival: _getLunarFestival(lunar),
      );
    } catch (e) {
      _logger.error('轉換公曆到農曆失敗', e);
      throw Exception('日期轉換失敗');
    }
  }

  /// 將農曆日期轉換為公曆日期
  DateTime lunarToSolar(int year, int month, int day, {bool isLeap = false}) {
    try {
      final lunar = Lunar.fromYmd(year, month, day, isLeap);
      return lunar.getSolar().toDate();
    } catch (e) {
      _logger.error('轉換農曆到公曆失敗', e);
      throw Exception('日期轉換失敗');
    }
  }

  /// 獲取當月的農曆日期列表
  List<app.LunarDate> getMonthLunarDates(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    final List<app.LunarDate> dates = [];
    for (var date = firstDay;
         date.isBefore(lastDay.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      dates.add(solarToLunar(date));
    }
    
    return dates;
  }

  /// 獲取當年的閏月（如果有的話）
  int? getLeapMonth(int year) {
    final leapMonth = LunarYear.fromYear(year).getLeapMonth();
    return leapMonth > 0 ? leapMonth : null;
  }

  /// 獲取指定農曆月份的天數
  int getDaysInLunarMonth(int year, int month, {bool isLeap = false}) {
    final lunar = Lunar.fromYmd(year, month, 1, isLeap);
    return lunar.getMonthDays();
  }

  /// 檢查指定年月日是否合法
  bool isValidLunarDate(int year, int month, int day, {bool isLeap = false}) {
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    
    try {
      final lunar = Lunar.fromYmd(year, month, day, isLeap);
      return lunar.getDay() == day; // 如果日期無效，lunar 會自動調整
    } catch (e) {
      return false;
    }
  }

  /// 獲取農曆節日
  String? _getLunarFestival(Lunar lunar) {
    final festivals = lunar.getFestivals();
    return festivals.isNotEmpty ? festivals.join(',') : null;
  }

  /// 獲取下一個節氣
  (String name, DateTime date) getNextSolarTerm(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final nextJieQi = lunar.getNextJieQi();
    return (nextJieQi.getName(), nextJieQi.getSolar().toDate());
  }

  /// 獲取當前節氣
  (String name, DateTime date) getCurrentSolarTerm(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final currentJieQi = lunar.getCurrentJieQi();
    return (currentJieQi.getName(), currentJieQi.getSolar().toDate());
  }

  /// 獲取今日時辰
  String getCurrentTimeZhi(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getTimeZhi();
  }

  /// 獲取八字
  (String year, String month, String day, String time) getBaZi(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return (
      '${lunar.getYearGan()}${lunar.getYearZhi()}',
      '${lunar.getMonthGan()}${lunar.getMonthZhi()}',
      '${lunar.getDayGan()}${lunar.getDayZhi()}',
      '${lunar.getTimeGan()}${lunar.getTimeZhi()}',
    );
  }

  /// 獲取日期宜忌
  ({List<String> yi, List<String> ji}) getDayLuck(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return (
      yi: lunar.getDayYi(),
      ji: lunar.getDayJi(),
    );
  }

  /// 獲取吉神方位
  List<String> getLuckyDirections(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getDayPositions();
  }

  /// 獲取每日運勢
  ({
    int score,
    String summary,
    List<String> details,
  }) getDayFortune(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final fortune = lunar.getDayFortune();
    return (
      score: fortune.getScore(),
      summary: fortune.getSummary(),
      details: fortune.getDetails(),
    );
  }

  /// 獲取胎神方位
  String getTaiShenDirection(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getDayTaishen();
  }

  /// 獲取彭祖百忌
  (String gan, String zhi) getPengZuAvoid(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return (
      lunar.getDayPengZuGan(),
      lunar.getDayPengZuZhi(),
    );
  }

  /// 獲取沖煞信息
  ({String animal, String direction, String description}) getConflict(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final conflict = lunar.getDayChongDesc();
    final sha = lunar.getDaySha();
    return (
      animal: lunar.getDayChongAnimal(),
      direction: conflict,
      description: sha,
    );
  }

  /// 獲取星座
  String getConstellation(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getXingZuo();
  }

  /// 獲取二十八宿
  String get28Stars(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getDayXiu();
  }

  /// 獲取日期的五行屬性
  String getDayWuXing(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getDayWuXing();
  }
} 