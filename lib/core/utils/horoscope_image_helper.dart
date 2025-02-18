import 'package:all_lucky/core/models/horoscope.dart';

class HoroscopeImageHelper {
  static const String _basePath = 'assets/images/horoscope';

  static String getHoroscopeImagePath(Horoscope horoscope) {
    final horoscopeName = _getEnglishName(horoscope);
    return '$_basePath/Western 12 Zodiacs - $horoscopeName.png';
  }

  static String _getEnglishName(Horoscope horoscope) {
    switch (horoscope) {
      case Horoscope.aries:
        return 'Aries';
      case Horoscope.taurus:
        return 'Taurus';
      case Horoscope.gemini:
        return 'Gemini';
      case Horoscope.cancer:
        return 'Cancer';
      case Horoscope.leo:
        return 'Leo';
      case Horoscope.virgo:
        return 'Virgo';
      case Horoscope.libra:
        return 'Libra';
      case Horoscope.scorpio:
        return 'Scorpio';
      case Horoscope.sagittarius:
        return 'Sagittarius';
      case Horoscope.capricorn:
        return 'Capricorn';
      case Horoscope.aquarius:
        return 'Aquarius';
      case Horoscope.pisces:
        return 'Pisces';
    }
  }

  static List<String> getAllHoroscopeImages() {
    return Horoscope.values.map((horoscope) => getHoroscopeImagePath(horoscope)).toList();
  }
} 