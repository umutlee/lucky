import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/utils/horoscope_image_helper.dart';

void main() {
  group('HoroscopeImageHelper Tests', () {
    test('getHoroscopeImage returns correct path for valid horoscope', () {
      const horoscope = '摩羯座';
      final imagePath = HoroscopeImageHelper.getHoroscopeImage(horoscope);
      expect(imagePath, 'assets/images/horoscope/Western 12 Zodiacs - Capricorn.png');
    });

    test('getHoroscopeImage throws ArgumentError for invalid horoscope', () {
      const invalidHoroscope = '無效星座';
      expect(
        () => HoroscopeImageHelper.getHoroscopeImage(invalidHoroscope),
        throwsArgumentError,
      );
    });

    test('getAllHoroscopeImages returns list with correct length', () {
      final images = HoroscopeImageHelper.getAllHoroscopeImages();
      expect(images.length, 12);
      expect(
        images.every((path) => path.startsWith('assets/images/horoscope/Western 12 Zodiacs - ')),
        true,
      );
    });

    test('isValidHoroscope returns correct boolean', () {
      expect(HoroscopeImageHelper.isValidHoroscope('摩羯座'), true);
      expect(HoroscopeImageHelper.isValidHoroscope('無效星座'), false);
    });

    test('getAllHoroscopeNames returns list with correct length and content', () {
      final names = HoroscopeImageHelper.getAllHoroscopeNames();
      expect(names.length, 12);
      expect(names.contains('摩羯座'), true);
      expect(names.contains('水瓶座'), true);
      expect(names.contains('無效星座'), false);
    });
  });
} 