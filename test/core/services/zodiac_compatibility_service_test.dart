import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/zodiac_compatibility_service.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

void main() {
  late ZodiacCompatibilityService service;

  setUp(() {
    service = ZodiacCompatibilityService();
  });

  group('ZodiacCompatibilityService', () {
    test('calculateCompatibility returns score within valid range', () {
      final score = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rat,
        FortuneType.career,
      );

      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(100.0));
    });

    test('calculateCompatibility considers base affinity', () {
      // 龍鼠相配
      final dragonRatScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rat,
        FortuneType.daily,
      );

      // 龍羊不合
      final dragonGoatScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.goat,
        FortuneType.daily,
      );

      expect(dragonRatScore, greaterThan(dragonGoatScore));
    });

    test('calculateCompatibility considers element compatibility', () {
      // 龍蛇同為土象
      final dragonSnakeScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.snake,
        FortuneType.daily,
      );

      // 龍雞五行相剋
      final dragonRoosterScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rooster,
        FortuneType.daily,
      );

      expect(dragonSnakeScore, greaterThan(dragonRoosterScore));
    });

    test('calculateCompatibility considers fortune type', () {
      // 龍虎在事業運勢中相配
      final careerScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.tiger,
        FortuneType.career,
      );

      // 同樣的生肖在愛情運勢中
      final loveScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.tiger,
        FortuneType.love,
      );

      expect(careerScore, greaterThan(loveScore));
    });

    test('calculateCompatibility considers time factor', () {
      final date = DateTime(2024, 1, 27); // 龍年
      
      final withDateScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rat,
        FortuneType.daily,
        date,
      );

      final withoutDateScore = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rat,
        FortuneType.daily,
      );

      expect(withDateScore, isNot(equals(withoutDateScore)));
    });

    test('getCompatibilityDescription returns appropriate description', () {
      final excellentDesc = service.getCompatibilityDescription(95.0);
      final goodDesc = service.getCompatibilityDescription(85.0);
      final normalDesc = service.getCompatibilityDescription(75.0);
      final poorDesc = service.getCompatibilityDescription(65.0);
      final badDesc = service.getCompatibilityDescription(55.0);

      expect(excellentDesc, contains('非常相配'));
      expect(goodDesc, contains('相性良好'));
      expect(normalDesc, contains('相處和睦'));
      expect(poorDesc, contains('普通相性'));
      expect(badDesc, contains('相性略低'));
    });

    test('getFortuneTypeAdvice returns appropriate advice', () {
      // 測試事業運勢建議
      final careerAdvice = service.getFortuneTypeAdvice(
        Zodiac.dragon,
        Zodiac.tiger,
        FortuneType.career,
        85.0,
      );

      expect(careerAdvice, isNotEmpty);
      expect(careerAdvice.first, contains('事業'));
      expect(careerAdvice.length, equals(2));

      // 測試學業運勢建議
      final studyAdvice = service.getFortuneTypeAdvice(
        Zodiac.rabbit,
        Zodiac.snake,
        FortuneType.study,
        85.0,
      );

      expect(studyAdvice, isNotEmpty);
      expect(studyAdvice.first, contains('學習'));
      expect(studyAdvice.length, equals(2));

      // 測試愛情運勢建議
      final loveAdvice = service.getFortuneTypeAdvice(
        Zodiac.goat,
        Zodiac.pig,
        FortuneType.love,
        85.0,
      );

      expect(loveAdvice, isNotEmpty);
      expect(loveAdvice.first, contains('感情'));
      expect(loveAdvice.length, equals(2));

      // 測試日常運勢建議
      final dailyAdvice = service.getFortuneTypeAdvice(
        Zodiac.rat,
        Zodiac.monkey,
        FortuneType.daily,
        85.0,
      );

      expect(dailyAdvice, isNotEmpty);
      expect(dailyAdvice.first, contains('日常'));
      expect(dailyAdvice.length, equals(2));
    });

    test('calculateCompatibility handles invalid input gracefully', () {
      // 測試空值處理
      final score = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rat,
        FortuneType.daily,
        null,
      );

      expect(score, isNotNull);
      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(100.0));
    });

    test('calculateCompatibility handles same zodiac', () {
      final score = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.dragon,
        FortuneType.daily,
      );

      expect(score, greaterThanOrEqualTo(70.0));
    });

    test('calculateCompatibility considers all factors', () {
      final date = DateTime(2024, 1, 27);
      final score = service.calculateCompatibility(
        Zodiac.dragon,
        Zodiac.rat,
        FortuneType.career,
        date,
      );

      // 檢查分數是否合理
      // 龍鼠相配(90分)，五行相生(90分)，事業運相關(95分)，時間因素(本命年90分)
      // 權重計算：90*0.4 + 90*0.3 + 95*0.2 + 90*0.1 = 91分
      expect(score, closeTo(91.0, 5.0));
    });
  });
} 