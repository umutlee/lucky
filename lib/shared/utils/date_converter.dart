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
  static String? getSolarTerm(DateTime date) {
    // TODO: 實現節氣判斷邏輯
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