import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/utils/zodiac_image_helper.dart';

void main() {
  group('ZodiacImageHelper Tests', () {
    test('getZodiacImage should return correct image path', () {
      expect(
        ZodiacImageHelper.getZodiacImage('鼠'),
        'assets/images/zodiac/Chinese 12 Zodiacs - Rat.png',
      );
      expect(
        ZodiacImageHelper.getZodiacImage('龍'),
        'assets/images/zodiac/Chinese 12 Zodiacs - Dragon.png',
      );
    });

    test('getZodiacImage should return default image for invalid zodiac', () {
      expect(
        ZodiacImageHelper.getZodiacImage('無效'),
        'assets/images/zodiac/Chinese 12 Zodiacs - Rat.png',
      );
    });

    test('getZodiacImageByYear should return correct zodiac for year', () {
      // 2020年是鼠年
      expect(
        ZodiacImageHelper.getZodiacImageByYear(2020),
        'assets/images/zodiac/Chinese 12 Zodiacs - Rat.png',
      );
      // 2024年是龍年
      expect(
        ZodiacImageHelper.getZodiacImageByYear(2024),
        'assets/images/zodiac/Chinese 12 Zodiacs - Dragon.png',
      );
    });

    test('getAllZodiacImages should return all 12 zodiac images', () {
      final allImages = ZodiacImageHelper.getAllZodiacImages();
      expect(allImages.length, 12);
      expect(
        allImages.first,
        'assets/images/zodiac/Chinese 12 Zodiacs - Rat.png',
      );
      expect(
        allImages.last,
        'assets/images/zodiac/Chinese 12 Zodiacs - Pig.png',
      );
    });
  });
} 