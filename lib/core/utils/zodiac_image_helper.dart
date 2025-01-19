class ZodiacImageHelper {
  static const _basePath = 'assets/images/zodiac/Chinese 12 Zodiacs - ';

  static String getZodiacImage(String zodiac) {
    if (!_zodiacNameMap.containsKey(zodiac)) {
      throw ArgumentError('Invalid zodiac name: $zodiac');
    }
    return '$_basePath${_zodiacNameMap[zodiac]}.jpg';
  }

  static String getZodiacImageByYear(int year) {
    final zodiacOrder = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
    final index = (year - 4) % 12; // 以4年為鼠年起始
    return getZodiacImage(zodiacOrder[index]);
  }

  // 獲取所有生肖圖片路徑
  static List<String> getAllZodiacImages() {
    return _zodiacNameMap.values.map((name) => '$_basePath$name.jpg').toList();
  }
} 