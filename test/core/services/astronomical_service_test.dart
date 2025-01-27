import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/astronomical_service.dart';

void main() {
  late AstronomicalService service;

  setUp(() {
    service = AstronomicalService();
  });

  group('AstronomicalService', () {
    test('getCurrentSolarTerm returns valid solar term', () {
      final (name, date) = service.getCurrentSolarTerm();
      expect(name, isNotEmpty);
      expect(date, isNotNull);
      expect(date.isBefore(DateTime.now().add(const Duration(days: 16))), isTrue);
    });

    test('getLunarDate returns valid lunar date', () {
      // 測試 2024 年農曆新年（2024年2月10日）
      final testDate = DateTime(2024, 2, 10);
      final (year, month, day) = service.getLunarDate(testDate);
      expect(year, 2024);
      expect(month, 1);
      expect(day, 1);
    });

    test('getMoonPhase returns value between 0 and 1', () {
      final phase = service.getMoonPhase();
      expect(phase, greaterThanOrEqualTo(0.0));
      expect(phase, lessThanOrEqualTo(1.0));
    });

    test('isLunarFestival correctly identifies festivals', () {
      // 測試 2024 年農曆新年
      expect(service.isLunarFestival(DateTime(2024, 2, 10)), isTrue);
      
      // 測試 2024 年元宵節
      expect(service.isLunarFestival(DateTime(2024, 2, 24)), isTrue);
      
      // 測試普通日期
      expect(service.isLunarFestival(DateTime(2024, 3, 1)), isFalse);
    });

    test('getNextSolarTerm returns valid next solar term', () {
      final testDate = DateTime(2024, 2, 1);
      final (name, date) = service.getNextSolarTerm(testDate);
      expect(name, isNotEmpty);
      expect(date.isAfter(testDate), isTrue);
      expect(date.isBefore(testDate.add(const Duration(days: 32))), isTrue);
    });

    test('getLunarDaysBetween calculates correct day difference', () {
      // 測試同一天
      expect(
        service.getLunarDaysBetween(
          DateTime(2024, 2, 10),
          DateTime(2024, 2, 10)
        ),
        0
      );

      // 測試相鄰兩天
      expect(
        service.getLunarDaysBetween(
          DateTime(2024, 2, 10),
          DateTime(2024, 2, 11)
        ),
        1
      );

      // 測試跨月
      expect(
        service.getLunarDaysBetween(
          DateTime(2024, 2, 10), // 農曆正月初一
          DateTime(2024, 3, 10)  // 農曆二月初一
        ),
        30
      );
    });

    test('handles invalid dates gracefully', () {
      // 測試無效日期
      final invalidDate = DateTime(1800, 1, 1); // 超出庫的支持範圍
      
      expect(
        () => service.getLunarDate(invalidDate),
        returnsNormally
      );
      
      expect(
        () => service.getMoonPhase(invalidDate),
        returnsNormally
      );
      
      expect(
        () => service.isLunarFestival(invalidDate),
        returnsNormally
      );
      
      expect(
        () => service.getNextSolarTerm(invalidDate),
        returnsNormally
      );
    });

    test('handles null dates by using current date', () {
      expect(() => service.getLunarDate(), returnsNormally);
      expect(() => service.getMoonPhase(), returnsNormally);
      expect(() => service.isLunarFestival(), returnsNormally);
      expect(() => service.getNextSolarTerm(), returnsNormally);
    });
  });
} 