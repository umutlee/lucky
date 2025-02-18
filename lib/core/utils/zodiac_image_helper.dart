import 'package:all_lucky/core/models/zodiac.dart';

class ZodiacImageHelper {
  static const String _basePath = 'assets/images/zodiac';

  static String getZodiacImagePath(Zodiac zodiac) {
    final zodiacName = _getEnglishName(zodiac);
    return '$_basePath/Chinese 12 Zodiacs - $zodiacName.png';
  }

  static String _getEnglishName(Zodiac zodiac) {
    switch (zodiac) {
      case Zodiac.rat:
        return 'Rat';
      case Zodiac.ox:
        return 'Ox';
      case Zodiac.tiger:
        return 'Tiger';
      case Zodiac.rabbit:
        return 'Rabbit';
      case Zodiac.dragon:
        return 'Dragon';
      case Zodiac.snake:
        return 'Snake';
      case Zodiac.horse:
        return 'Horse';
      case Zodiac.goat:
        return 'Goat';
      case Zodiac.monkey:
        return 'Monkey';
      case Zodiac.rooster:
        return 'Rooster';
      case Zodiac.dog:
        return 'Dog';
      case Zodiac.pig:
        return 'Pig';
    }
  }

  static List<String> getAllZodiacImages() {
    return Zodiac.values.map((zodiac) => getZodiacImagePath(zodiac)).toList();
  }
} 