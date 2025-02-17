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
    required List<String> positions,
    required int year,
    required int month,
    required int day,
    @Default(false) bool isLeapMonth,
  }) = _LunarDate;

  factory LunarDate.fromJson(Map<String, dynamic> json) =>
      _$LunarDateFromJson(json);

  const LunarDate._();

  String get lunarDateString {
    final monthNames = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '臘'];
    final dayNames = [
      '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
    ];
    
    final yearString = heavenlyStem + earthlyBranch;
    final monthString = '${isLeapMonth ? "閏" : ""}${monthNames[month - 1]}';
    final dayString = dayNames[day - 1];
    
    return '$yearString年$monthString月$dayString';
  }

  String get stemBranchYear => '$heavenlyStem$earthlyBranch年';

  @override
  String toString() => lunarDateString;
}