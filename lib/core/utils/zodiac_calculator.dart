class ZodiacCalculator {
  static const List<String> _zodiacSigns = [
    '鼠', '牛', '虎', '兔', '龍', '蛇',
    '馬', '羊', '猴', '雞', '狗', '豬'
  ];

  /// 根據出生年份計算生肖
  static String calculateZodiac(DateTime birthDate) {
    // 中國生肖以農曆年為準，這裡使用簡化計算
    // 1900年是鼠年
    final year = birthDate.year;
    final index = (year - 1900) % 12;
    return _zodiacSigns[index];
  }

  /// 獲取所有生肖
  static List<String> getAllZodiacSigns() {
    return List.from(_zodiacSigns);
  }

  /// 獲取生肖的索引
  static int getZodiacIndex(String zodiac) {
    return _zodiacSigns.indexOf(zodiac);
  }

  /// 檢查是否為有效的生肖
  static bool isValidZodiac(String zodiac) {
    return _zodiacSigns.contains(zodiac);
  }
} 