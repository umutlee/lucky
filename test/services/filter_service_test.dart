import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/filter_service.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/filter_criteria.dart';
import 'package:all_lucky/core/models/zodiac.dart';

void main() {
  late FilterService filterService;

  setUp(() {
    filterService = FilterService();
  });

  group('Fortune Filtering Tests', () {
    final testFortune1 = Fortune(
      id: '1',
      type: 'career',
      score: 85,
      description: 'Good day for career',
      date: DateTime.now(),
      luckyTimes: ['Morning', 'Evening'],
      luckyDirections: ['North', 'South'],
      luckyColors: ['Red', 'Blue'],
      luckyNumbers: [1, 8],
      suggestions: ['Focus on work'],
      warnings: ['Avoid conflicts'],
      createdAt: DateTime.now(),
      isLuckyDay: true,
      suitableActivities: ['Meeting', 'Planning'],
      zodiac: Zodiac.dragon,
      zodiacAffinity: 80,
      recommendations: ['Work with Tiger'],
    );

    final testFortune2 = Fortune(
      id: '2',
      type: 'love',
      score: 75,
      description: 'Average day for love',
      date: DateTime.now(),
      luckyTimes: ['Afternoon'],
      luckyDirections: ['East'],
      luckyColors: ['Pink'],
      luckyNumbers: [2, 7],
      suggestions: ['Be patient'],
      warnings: ['Don\'t rush'],
      createdAt: DateTime.now(),
      isLuckyDay: false,
      suitableActivities: ['Dating'],
      zodiac: Zodiac.rabbit,
      zodiacAffinity: 70,
      recommendations: ['Meet new people'],
    );

    test('Filter by type', () {
      final criteria = FilterCriteria(type: 'career');
      final results = filterService.filterFortunes(
        [testFortune1, testFortune2],
        criteria,
      );
      expect(results.length, 1);
      expect(results.first.type, 'career');
    });

    test('Filter by score range', () {
      final criteria = FilterCriteria(
        minScore: 80,
        maxScore: 90,
      );
      final results = filterService.filterFortunes(
        [testFortune1, testFortune2],
        criteria,
      );
      expect(results.length, 1);
      expect(results.first.score, 85);
    });

    test('Filter by lucky day', () {
      final criteria = FilterCriteria(isLuckyDay: true);
      final results = filterService.filterFortunes(
        [testFortune1, testFortune2],
        criteria,
      );
      expect(results.length, 1);
      expect(results.first.isLuckyDay, true);
    });

    test('Sort by date ascending', () {
      final criteria = FilterCriteria(
        sortField: SortField.date,
        sortOrder: SortOrder.ascending,
      );
      final results = filterService.filterFortunes(
        [testFortune2, testFortune1],
        criteria,
      );
      expect(results.first.id, testFortune1.id);
    });

    test('Sort by score descending', () {
      final criteria = FilterCriteria(
        sortField: SortField.score,
        sortOrder: SortOrder.descending,
      );
      final results = filterService.filterFortunes(
        [testFortune2, testFortune1],
        criteria,
      );
      expect(results.first.score, 85);
    });

    test('Filter by date range', () {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      final tomorrow = now.add(Duration(days: 1));
      
      final criteria = FilterCriteria(
        startDate: yesterday,
        endDate: tomorrow,
      );
      final results = filterService.filterFortunes(
        [testFortune1, testFortune2],
        criteria,
      );
      expect(results.length, 2);
    });

    test('Filter by activities', () {
      final criteria = FilterCriteria(
        activities: ['Meeting'],
      );
      final results = filterService.filterFortunes(
        [testFortune1, testFortune2],
        criteria,
      );
      expect(results.length, 1);
      expect(results.first.suitableActivities, contains('Meeting'));
    });
  });
} 