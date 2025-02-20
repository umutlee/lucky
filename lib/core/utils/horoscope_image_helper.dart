import '../models/horoscope.dart';

class HoroscopeImageHelper {
  static String getImagePath(Horoscope horoscope) {
    final name = horoscope.name[0].toUpperCase() + horoscope.name.substring(1).toLowerCase();
    return 'assets/images/horoscope/Western 12 Zodiacs - $name.jpg';
  }

  static List<String> getAllHoroscopeImages() {
    return Horoscope.values.map((horoscope) => getImagePath(horoscope)).toList();
  }
}