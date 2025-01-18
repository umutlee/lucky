class ZodiacImageHelper {
  static const _basePath = 'assets/images/zodiac/Chinese 12 Zodiacs - ';

  static String getZodiacImage(String zodiac) {
    final mapping = {
      '鼠': 'Rat',
      '牛': 'Ox',
      '虎': 'Tiger',
      '兔': 'Rabbit',
      '龍': 'Dragon',
      '蛇': 'Snake',
      '馬': 'Horse',
      '羊': 'Goat',
      '猴': 'Monkey',
      '雞': 'Rooster',
      '狗': 'Dog',
      '豬': 'Pig',
    };

    final englishName = mapping[zodiac] ?? 'Rat';
    return '$_basePath$englishName.png';
  }

  static String getZodiacImageByYear(int year) {
    final zodiacOrder = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
    final index = (year - 4) % 12; // 以4年為鼠年起始
    return getZodiacImage(zodiacOrder[index]);
  }

  // 獲取所有生肖圖片路徑
  static List<String> getAllZodiacImages() {
    return [
      '鼠', '牛', '虎', '兔', '龍', '蛇',
      '馬', '羊', '猴', '雞', '狗', '豬'
    ].map((zodiac) => getZodiacImage(zodiac)).toList();
  }
} 