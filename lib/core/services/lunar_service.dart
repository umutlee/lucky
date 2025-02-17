import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/lunar_wrapper.dart';
import '../models/lunar_date.dart' as app;
import '../utils/logger.dart';

/// 農曆服務提供者
final lunarServiceProvider = Provider<LunarService>((ref) {
  return LunarService();
});

/// 農曆服務
class LunarService {
  /// 獲取農曆日期
  ({
    int year,
    int month,
    int day,
    bool isLeapMonth,
  }) getLunarDate(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );

    return (
      year: date.year,
      month: date.month,
      day: date.day,
      isLeapMonth: lunar.isLeap(),
    );
  }

  /// 從農曆日期獲取陽曆日期
  DateTime getSolarDate({
    required int year,
    required int month,
    required int day,
    bool isLeap = false,
  }) {
    final lunar = LunarWrapper.fromLunar(year, month, day, isLeap: isLeap);
    return DateTime(year, month, day);
  }

  /// 獲取當月天數
  int getDaysInMonth({
    required int year,
    required int month,
    bool isLeap = false,
  }) {
    final lunar = LunarWrapper.fromLunar(year, month, 1, isLeap: isLeap);
    return DateTime(year, month + 1, 0).day;
  }

  /// 獲取下一個節氣
  (String name, DateTime date) getNextJieQi(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getNextJieQi();
  }

  /// 獲取當前節氣
  (String name, DateTime date) getCurrentJieQi(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getCurrentJieQi();
  }

  /// 獲取日位置
  List<String> getDayPositions(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getDayPositions();
  }

  /// 獲取日運勢
  String getDayFortune(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getDayFortune();
  }

  /// 獲取太歲
  String getDayTaishen(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getDayTaishen();
  }

  /// 獲取日干支
  (String gan, String zhi) getDayGanZhi(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return (
      gan: lunar.getDayPengZuGan(),
      zhi: lunar.getDayPengZuZhi(),
    );
  }

  /// 獲取沖煞
  ({String animal}) getDayChong(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return (animal: lunar.getDayChongAnimal());
  }

  /// 獲取星座
  String getXingZuo(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getXingZuo();
  }

  /// 獲取二十八宿
  String getDayXiu(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getDayXiu();
  }

  /// 獲取五行
  String getDayWuXing(DateTime date) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );
    return lunar.getDayWuXing();
  }
} 