import 'package:meta/meta.dart';

/// 農曆日期模型
/// 包含農曆日期的基本信息
@immutable
class LunarDate {
  /// 農曆年份
  final int year;
  
  /// 農曆月份（1-12）
  final int month;
  
  /// 農曆日期（1-30）
  final int day;
  
  /// 是否閏月
  final bool isLeapMonth;
  
  /// 天干
  final String heavenlyStem;
  
  /// 地支
  final String earthlyBranch;
  
  /// 生肖
  final String zodiac;
  
  /// 農曆節氣
  final String? solarTerm;
  
  /// 農曆節日
  final String? festival;

  /// 構造函數
  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    required this.isLeapMonth,
    required this.heavenlyStem,
    required this.earthlyBranch,
    required this.zodiac,
    this.solarTerm,
    this.festival,
  });

  /// 從 JSON 創建實例
  factory LunarDate.fromJson(Map<String, dynamic> json) {
    return LunarDate(
      year: json['year'] as int,
      month: json['month'] as int,
      day: json['day'] as int,
      isLeapMonth: json['isLeapMonth'] as bool,
      heavenlyStem: json['heavenlyStem'] as String,
      earthlyBranch: json['earthlyBranch'] as String,
      zodiac: json['zodiac'] as String,
      solarTerm: json['solarTerm'] as String?,
      festival: json['festival'] as String?,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'isLeapMonth': isLeapMonth,
      'heavenlyStem': heavenlyStem,
      'earthlyBranch': earthlyBranch,
      'zodiac': zodiac,
      'solarTerm': solarTerm,
      'festival': festival,
    };
  }

  /// 獲取農曆日期的字符串表示
  /// 例如：二零二四年正月初一
  String get lunarDateString {
    final monthNames = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '臘'];
    final dayNames = [
      '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
    ];
    
    final yearString = year.toString()
        .split('')
        .map((digit) => ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'][int.parse(digit)])
        .join('');
    
    final monthString = '${isLeapMonth ? "閏" : ""}${monthNames[month - 1]}';
    final dayString = dayNames[day - 1];
    
    return '$yearString年$monthString月$dayString';
  }

  /// 獲取干支紀年
  String get stemBranchYear => '$heavenlyStem$earthlyBranch年';

  @override
  String toString() => lunarDateString;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LunarDate &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.isLeapMonth == isLeapMonth;
  }

  @override
  int get hashCode => Object.hash(year, month, day, isLeapMonth);
} 