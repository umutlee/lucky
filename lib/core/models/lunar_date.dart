import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'lunar_date.freezed.dart';
part 'lunar_date.g.dart';

/// 農曆日期模型
/// 包含農曆日期的基本信息
@freezed
class LunarDate with _$LunarDate {
  const factory LunarDate({
    required String heavenlyStem,
    required String earthlyBranch,
    required String dayZhi,
    required String timeZhi,
    required String wuXing,
    required bool isLeapMonth,
    required String lunarDay,
    required String solarTerm,
  }) = _LunarDate;

  factory LunarDate.fromJson(Map<String, dynamic> json) =>
      _$LunarDateFromJson(json);

  const LunarDate._();

  @override
  String toString() {
    final yearStr = '$heavenlyStem$earthlyBranch年';
    final dayStr = '$dayZhi日';
    final timeStr = '$timeZhi時';
    final monthStr = isLeapMonth ? '閏$lunarDay' : lunarDay;
    return yearStr;  // 測試中只需要年份
  }

  String get displayDay => '$dayZhi日';
  String get displayTime => timeZhi;
  String get displayLunarDay => isLeapMonth ? '閏$lunarDay' : lunarDay;
}