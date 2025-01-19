class HoroscopeImageHelper {
  static const String _basePath = 'assets/images/horoscope/Western 12 Zodiacs - ';
  
  static final Map<String, String> _horoscopeNameMap = {
    '摩羯座': 'Capricorn',
    '水瓶座': 'Aquarius',
    '雙魚座': 'Pisces',
    '白羊座': 'Aries',
    '金牛座': 'Taurus',
    '雙子座': 'Gemini',
    '巨蟹座': 'Cancer',
    '獅子座': 'Leo',
    '處女座': 'Virgo',
    '天秤座': 'Libra',
    '天蠍座': 'Scorpio',
    '射手座': 'Sagittarius',
  };

  static String getHoroscopeImage(String horoscope) {
    final englishName = _horoscopeNameMap[horoscope];
    if (englishName == null) {
      throw ArgumentError('Invalid horoscope name: $horoscope');
    }
    return '$_basePath$englishName.png';
  }

  static List<String> getAllHoroscopeImages() {
    return _horoscopeNameMap.values.map((name) => '$_basePath$name.png').toList();
  }

  static bool isValidHoroscope(String horoscope) {
    return _horoscopeNameMap.containsKey(horoscope);
  }

  static List<String> getAllHoroscopeNames() {
    return _horoscopeNameMap.keys.toList();
  }
} 