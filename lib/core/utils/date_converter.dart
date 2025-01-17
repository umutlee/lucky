/// 日期轉換工具類
class DateConverter {
  /// 2024年節氣日期（格式：MM-dd）
  static const Map<String, String> _solarTerms2024 = {
    '小寒': '01-06',
    '大寒': '01-20',
    '立春': '02-04',
    '雨水': '02-19',
    '驚蟄': '03-05',
    '春分': '03-20',
    '清明': '04-04',
    '穀雨': '04-19',
    '立夏': '05-05',
    '小滿': '05-20',
    '芒種': '06-05',
    '夏至': '06-21',
    '小暑': '07-06',
    '大暑': '07-22',
    '立秋': '08-07',
    '處暑': '08-23',
    '白露': '09-07',
    '秋分': '09-22',
    '寒露': '10-08',
    '霜降': '10-23',
    '立冬': '11-07',
    '小雪': '11-22',
    '大雪': '12-07',
    '冬至': '12-21',
  };

  /// 獲取指定日期的節氣
  /// 
  /// [date] 日期字符串，格式：yyyy-MM-dd
  /// 返回節氣名稱，如果不是節氣日則返回 null
  static String? getSolarTerm(String date) {
    // 解析年份和日期
    final parts = date.split('-');
    if (parts.length != 3) return null;
    
    final year = int.tryParse(parts[0]);
    if (year == null) return null;

    // 獲取當年節氣數據
    final solarTerms = _getSolarTermsForYear(year);
    if (solarTerms == null) return null;

    // 格式化日期為 MM-dd 格式
    final monthDay = '${parts[1]}-${parts[2]}';

    // 查找對應節氣
    for (final entry in solarTerms.entries) {
      if (entry.value == monthDay) {
        return entry.key;
      }
    }

    return null;
  }

  /// 獲取指定年份的節氣數據
  static Map<String, String>? _getSolarTermsForYear(int year) {
    // 目前僅支持 2024 年
    // TODO: 添加其他年份的節氣數據
    if (year == 2024) {
      return _solarTerms2024;
    }
    return null;
  }

  /// 格式化日期為字符串
  /// 
  /// [date] DateTime 對象
  /// 返回格式：yyyy-MM-dd
  static String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 解析日期字符串
  /// 
  /// [dateStr] 日期字符串，格式：yyyy-MM-dd
  /// 返回 DateTime 對象，如果解析失敗則返回 null
  static DateTime? parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;

      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);

      if (year == null || month == null || day == null) return null;
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 31) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// 獲取當前日期
  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }

  /// 獲取指定日期的年份
  static int? getYear(String date) {
    final dateTime = parseDate(date);
    return dateTime?.year;
  }

  /// 獲取指定日期的月份
  static int? getMonth(String date) {
    final dateTime = parseDate(date);
    return dateTime?.month;
  }

  /// 獲取指定日期的日
  static int? getDay(String date) {
    final dateTime = parseDate(date);
    return dateTime?.day;
  }

  /// 檢查日期是否有效
  static bool isValidDate(String date) {
    return parseDate(date) != null;
  }
} 