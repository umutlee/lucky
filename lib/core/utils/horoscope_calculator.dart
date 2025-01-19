class HoroscopeCalculator {
  static const List<String> _horoscopeSigns = [
    '摩羯座', '水瓶座', '雙魚座', '白羊座', '金牛座', '雙子座',
    '巨蟹座', '獅子座', '處女座', '天秤座', '天蠍座', '射手座'
  ];

  static const List<List<int>> _horoscopeDates = [
    [1, 20],  // 摩羯座結束日期
    [2, 18],  // 水瓶座結束日期
    [3, 20],  // 雙魚座結束日期
    [4, 19],  // 白羊座結束日期
    [5, 20],  // 金牛座結束日期
    [6, 21],  // 雙子座結束日期
    [7, 22],  // 巨蟹座結束日期
    [8, 22],  // 獅子座結束日期
    [9, 22],  // 處女座結束日期
    [10, 23], // 天秤座結束日期
    [11, 22], // 天蠍座結束日期
    [12, 21]  // 射手座結束日期
  ];

  /// 根據出生日期計算星座
  static String calculateHoroscope(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    
    // 檢查是否在當前月份的星座範圍內
    if (day > _horoscopeDates[month - 1][1]) {
      return _horoscopeSigns[month % 12];
    } else {
      return _horoscopeSigns[(month - 1) % 12];
    }
  }

  /// 獲取所有星座
  static List<String> getAllHoroscopeSigns() {
    return List.from(_horoscopeSigns);
  }

  /// 獲取星座的索引
  static int getHoroscopeIndex(String horoscope) {
    return _horoscopeSigns.indexOf(horoscope);
  }

  /// 檢查是否為有效的星座
  static bool isValidHoroscope(String horoscope) {
    return _horoscopeSigns.contains(horoscope);
  }

  /// 獲取星座的日期範圍
  static String getHoroscopeDateRange(String horoscope) {
    final index = getHoroscopeIndex(horoscope);
    if (index == -1) return '';
    
    final startMonth = (index == 0) ? 12 : index;
    final endMonth = (index + 1) % 12;
    final startDay = _horoscopeDates[(index - 1 + 12) % 12][1] + 1;
    final endDay = _horoscopeDates[index][1];
    
    return '$startMonth月$startDay日 - $endMonth月$endDay日';
  }
} 