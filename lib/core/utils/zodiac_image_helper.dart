import '../models/zodiac.dart';

class ZodiacImageHelper {
  static const _basePath = 'assets/images/zodiac/';

  static const _zodiacNameMap = {
    Zodiac.rat: 'Chinese 12 Zodiacs - Rat',
    Zodiac.ox: 'Chinese 12 Zodiacs - Ox',
    Zodiac.tiger: 'Chinese 12 Zodiacs - Tiger',
    Zodiac.rabbit: 'Chinese 12 Zodiacs - Rabbit',
    Zodiac.dragon: 'Chinese 12 Zodiacs - Dragon',
    Zodiac.snake: 'Chinese 12 Zodiacs - Snake',
    Zodiac.horse: 'Chinese 12 Zodiacs - Horse',
    Zodiac.goat: 'Chinese 12 Zodiacs - Goat',
    Zodiac.monkey: 'Chinese 12 Zodiacs - Monkey',
    Zodiac.rooster: 'Chinese 12 Zodiacs - Rooster',
    Zodiac.dog: 'Chinese 12 Zodiacs - Dog',
    Zodiac.pig: 'Chinese 12 Zodiacs - Pig',
  };

  static String getZodiacImage(Zodiac zodiac) {
    final name = _zodiacNameMap[zodiac];
    if (name == null) {
      throw ArgumentError('無效的生肖: $zodiac');
    }
    return 'assets/images/zodiac/$name.jpg';
  }

  static String getZodiacImageByYear(int year) {
    final zodiac = Zodiac.fromYear(year);
    return getZodiacImage(zodiac);
  }

  static List<String> getAllZodiacImages() {
    return _zodiacNameMap.values
        .map((name) => 'assets/images/zodiac/$name.jpg')
        .toList();
  }
} 