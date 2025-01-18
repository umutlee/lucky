import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/lucky_day_service.dart';
import 'package:all_lucky/core/models/lucky_day.dart';

void main() {
  late LuckyDayService luckyDayService;
  final today = DateTime.now();

  setUp(() {
    luckyDayService = LuckyDayService();
  });

  group('吉日服務測試', () {
    test('獲取下一個吉日', () async {
      final nextLuckyDay = await luckyDayService.getNextLuckyDay(today);
      
      expect(nextLuckyDay, isNotNull);
      expect(nextLuckyDay!.date.isAfter(today), isTrue);
      expect(nextLuckyDay.description, isNotEmpty);
      expect(nextLuckyDay.suitableActivities, isNotEmpty);
      expect(nextLuckyDay.luckyDirections, isNotEmpty);
      expect(nextLuckyDay.score, isNotNull);
    });

    test('獲取多個吉日', () async {
      final luckyDays = await luckyDayService.getNextLuckyDays(today, limit: 3);
      
      expect(luckyDays.length, equals(3));
      expect(luckyDays.first.date.isAfter(today), isTrue);
      expect(luckyDays.last.date.isAfter(luckyDays.first.date), isTrue);
    });

    test('獲取日期範圍內的吉日', () async {
      final start = today;
      final end = today.add(const Duration(days: 30));
      final luckyDays = await luckyDayService.getLuckyDaysInRange(start, end);
      
      for (final luckyDay in luckyDays) {
        expect(luckyDay.date.isAfter(start), isTrue);
        expect(luckyDay.date.isBefore(end), isTrue);
      }
    });

    test('空日期範圍應返回空列表', () async {
      final start = today;
      final end = today.subtract(const Duration(days: 1)); // 結束日期在開始日期之前
      final luckyDays = await luckyDayService.getLuckyDaysInRange(start, end);
      
      expect(luckyDays, isEmpty);
    });

    test('按活動類型獲取吉日', () async {
      const activity = '考試';
      final luckyDays = await luckyDayService.getLuckyDaysByActivity(activity);
      
      for (final luckyDay in luckyDays) {
        expect(luckyDay.suitableActivities, contains(activity));
      }
    });

    test('吉日數據格式正確', () async {
      final luckyDays = await luckyDayService.getNextLuckyDays(today);
      
      for (final luckyDay in luckyDays) {
        expect(luckyDay.date, isNotNull);
        expect(luckyDay.description, isNotEmpty);
        expect(luckyDay.suitableActivities, isNotNull);
        expect(luckyDay.luckyDirections, isNotNull);
        expect(luckyDay.score, isNotNull);
        expect(luckyDay.score, greaterThanOrEqualTo(0));
        expect(luckyDay.score, lessThanOrEqualTo(100));
      }
    });

    test('不存在的活動類型應返回空列表', () async {
      const nonExistentActivity = '不存在的活動';
      final luckyDays = await luckyDayService.getLuckyDaysByActivity(nonExistentActivity);
      
      expect(luckyDays, isEmpty);
    });
  });
} 