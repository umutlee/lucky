import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/core/services/time_factor_service.dart';
import 'package:all_lucky/core/services/astronomical_service.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

class MockAstronomicalService extends Mock implements AstronomicalService {
  @override
  (String name, DateTime date) getCurrentSolarTerm() {
    return ('立春', DateTime(2024, 2, 4));
  }

  @override
  (String name, DateTime date) getNextSolarTerm([DateTime? date]) {
    date ??= DateTime.now();
    return ('雨水', date.add(const Duration(days: 15)));
  }

  @override
  (int year, int month, int day) getLunarDate([DateTime? date]) {
    return (2024, 1, 1);
  }

  @override
  double getMoonPhase([DateTime? date]) {
    return 0.5;
  }

  @override
  bool isLunarFestival([DateTime? date]) {
    return false;
  }
}

void main() {
  late TimeFactorService service;
  late MockAstronomicalService mockAstronomicalService;

  setUp(() {
    mockAstronomicalService = MockAstronomicalService();
    service = TimeFactorService(mockAstronomicalService);
  });

  group('TimeFactorService', () {
    test('calculateTimeFactorScore returns value between 0 and 1', () {
      final testDate = DateTime(2024, 2, 10);
      final score = service.calculateTimeFactorScore(FortuneType.daily, testDate);
      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(1.0));
    });

    test('calculateTimeFactorScore adjusts weights for study fortune', () {
      final weekdayScore = service.calculateTimeFactorScore(
        FortuneType.study,
        DateTime(2024, 2, 7) // 週三
      );
      
      final weekendScore = service.calculateTimeFactorScore(
        FortuneType.study,
        DateTime(2024, 2, 10) // 週六
      );
      
      expect(weekdayScore, greaterThan(weekendScore));
    });

    test('calculateTimeFactorScore adjusts weights for career fortune', () {
      final weekdayScore = service.calculateTimeFactorScore(
        FortuneType.career,
        DateTime(2024, 2, 6) // 週二
      );
      
      final weekendScore = service.calculateTimeFactorScore(
        FortuneType.career,
        DateTime(2024, 2, 10) // 週六
      );
      
      expect(weekdayScore, greaterThan(weekendScore));
    });

    test('calculateTimeFactorScore adjusts weights for love fortune', () {
      final weekdayScore = service.calculateTimeFactorScore(
        FortuneType.love,
        DateTime(2024, 2, 7) // 週三
      );
      
      final weekendScore = service.calculateTimeFactorScore(
        FortuneType.love,
        DateTime(2024, 2, 10) // 週六
      );
      
      expect(weekendScore, greaterThan(weekdayScore));
    });

    test('calculateTimeFactorScore considers hour of day', () {
      final morningScore = service.calculateTimeFactorScore(
        FortuneType.study,
        DateTime(2024, 2, 7, 9) // 早上 9 點
      );
      
      final nightScore = service.calculateTimeFactorScore(
        FortuneType.study,
        DateTime(2024, 2, 7, 23) // 晚上 11 點
      );
      
      expect(morningScore, greaterThan(nightScore));
    });

    test('calculateTimeFactorScore considers lunar date', () {
      when(mockAstronomicalService.getLunarDate(any))
        .thenReturn((2024, 1, 1)); // 農曆新年
      
      final festivalScore = service.calculateTimeFactorScore(
        FortuneType.daily,
        DateTime(2024, 2, 10)
      );
      
      when(mockAstronomicalService.getLunarDate(any))
        .thenReturn((2024, 1, 2)); // 初二
      
      final normalScore = service.calculateTimeFactorScore(
        FortuneType.daily,
        DateTime(2024, 2, 11)
      );
      
      expect(festivalScore, greaterThan(normalScore));
    });

    test('calculateTimeFactorScore considers moon phase', () {
      when(mockAstronomicalService.getMoonPhase(any))
        .thenReturn(1.0); // 滿月
      
      final fullMoonScore = service.calculateTimeFactorScore(
        FortuneType.love,
        DateTime(2024, 2, 10)
      );
      
      when(mockAstronomicalService.getMoonPhase(any))
        .thenReturn(0.0); // 新月
      
      final newMoonScore = service.calculateTimeFactorScore(
        FortuneType.love,
        DateTime(2024, 2, 24)
      );
      
      expect(fullMoonScore, greaterThan(newMoonScore));
    });

    test('calculateTimeFactorScore considers season', () {
      final springScore = service.calculateTimeFactorScore(
        FortuneType.study,
        DateTime(2024, 4, 15) // 春季
      );
      
      final summerScore = service.calculateTimeFactorScore(
        FortuneType.study,
        DateTime(2024, 7, 15) // 夏季
      );
      
      expect(springScore, greaterThan(summerScore));
    });

    test('isSpecialDate identifies special dates correctly', () {
      when(mockAstronomicalService.isLunarFestival(any))
        .thenReturn(true);
      
      expect(
        service.isSpecialDate(DateTime(2024, 2, 10)),
        isTrue
      );
      
      when(mockAstronomicalService.isLunarFestival(any))
        .thenReturn(false);
      
      expect(
        service.isSpecialDate(DateTime(2024, 2, 11)),
        isFalse
      );
    });

    test('handles errors gracefully', () {
      when(mockAstronomicalService.getLunarDate(any))
        .thenThrow(Exception('測試錯誤'));
      
      expect(
        () => service.calculateTimeFactorScore(FortuneType.daily),
        returnsNormally
      );
    });
  });
} 