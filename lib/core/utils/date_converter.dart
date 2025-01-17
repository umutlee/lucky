import 'package:intl/intl.dart';
import '../../core/models/lunar_date.dart';

/// 日期轉換工具類
class DateConverter {
  DateConverter._();

  /// 天干
  static const List<String> heavenlyStems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  
  /// 地支
  static const List<String> earthlyBranches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
  
  /// 生肖
  static const List<String> zodiacSigns = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
  
  /// 節氣
  static const List<String> solarTerms = [
    '小寒', '大寒', '立春', '雨水', '驚蟄', '春分',
    '清明', '穀雨', '立夏', '小滿', '芒種', '夏至',
    '小暑', '大暑', '立秋', '處暑', '白露', '秋分',
    '寒露', '霜降', '立冬', '小雪', '大雪', '冬至'
  ];

  /// 2024年節氣時間（未來可改為從API獲取）
  static const Map<String, String> _solarTerms2024 = {
    '小寒': '2024-01-06 04:49',
    '大寒': '2024-01-20 22:07',
    '立春': '2024-02-04 16:27',
    '雨水': '2024-02-19 11:13',
    '驚蟄': '2024-03-05 06:22',
    '春分': '2024-03-20 00:06',
    '清明': '2024-04-04 16:02',
    '穀雨': '2024-04-20 05:19',
    '立夏': '2024-05-05 15:50',
    '小滿': '2024-05-21 00:00',
    '芒種': '2024-06-05 06:09',
    '夏至': '2024-06-21 10:51',
    '小暑': '2024-07-06 15:20',
    '大暑': '2024-07-22 20:44',
    '立秋': '2024-08-07 03:29',
    '處暑': '2024-08-23 11:55',
    '白露': '2024-09-07 22:11',
    '秋分': '2024-09-22 10:44',
    '寒露': '2024-10-08 01:59',
    '霜降': '2024-10-23 19:44',
    '立冬': '2024-11-07 15:34',
    '小雪': '2024-11-22 13:56',
    '大雪': '2024-12-07 14:17',
    '冬至': '2024-12-21 16:21',
  };

  /// 格式化公曆日期
  static String formatSolarDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_TW').format(date);
  }

  /// 獲取星期幾
  static String getWeekday(DateTime date) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '星期${weekdays[date.weekday - 1]}';
  }

  /// 計算年份的天干地支
  static (String, String) getStemBranch(int year) {
    final stemIndex = (year - 4) % 10;
    final branchIndex = (year - 4) % 12;
    
    return (
      heavenlyStems[stemIndex],
      earthlyBranches[branchIndex],
    );
  }

  /// 獲取生肖
  static String getZodiac(int year) {
    return zodiacSigns[(year - 4) % 12];
  }

  /// 判斷是否為節氣日
  /// 
  /// [date] 要判斷的日期
  /// 返回節氣名稱，如果不是節氣日則返回 null
  static String? getSolarTerm(DateTime date) {
    // 獲取當年節氣數據
    final solarTermsData = _getSolarTermsForYear(date.year);
    if (solarTermsData == null) return null;

    // 格式化日期為 yyyy-MM-dd 格式
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // 檢查是否是節氣日
    for (final entry in solarTermsData.entries) {
      if (entry.value.startsWith(dateStr)) {
        return entry.key;
      }
    }

    return null;
  }

  /// 獲取指定年份的節氣數據
  /// 
  /// [year] 年份
  /// 返回該年份的節氣數據，如果沒有該年份的數據則返回 null
  static Map<String, String>? _getSolarTermsForYear(int year) {
    // 目前僅支援2024年，未來可擴展或從API獲取
    if (year == 2024) {
      return _solarTerms2024;
    }
    return null;
  }

  /// 判斷是否為農曆節日
  static String? getLunarFestival(LunarDate lunarDate) {
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

  /// 獲取今日時辰
  static List<String> getTodayHours() {
    const hours = [
      '子時（23:00-1:00）',
      '丑時（1:00-3:00）',
      '寅時（3:00-5:00）',
      '卯時（5:00-7:00）',
      '辰時（7:00-9:00）',
      '巳時（9:00-11:00）',
      '午時（11:00-13:00）',
      '未時（13:00-15:00）',
      '申時（15:00-17:00）',
      '酉時（17:00-19:00）',
      '戌時（19:00-21:00）',
      '亥時（21:00-23:00）',
    ];
    
    return hours;
  }
} 