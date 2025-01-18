import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/filter_criteria.dart';
import 'package:all_lucky/core/services/filter_service.dart';

void main() {
  late FilterService filterService;
  late List<Fortune> testFortunes;

  setUp(() {
    filterService = FilterService();
    
    // 準備測試數據
    testFortunes = [
      Fortune(
        type: FortuneType.overall,
        score: 85,
        date: DateTime(2024, 1, 18),
        isLuckyDay: true,
        luckyDirections: ['東', '南'],
        suitableActivities: ['求財', '考試'],
        description: '今日大吉',
      ),
      Fortune(
        type: FortuneType.study,
        score: 60,
        date: DateTime(2024, 1, 19),
        isLuckyDay: false,
        luckyDirections: ['西', '北'],
        suitableActivities: ['考試', '讀書'],
        description: '適合學習',
      ),
    ];
  });

  group('FilterService - 篩選測試', () {
    test('空的篩選條件應該返回原始列表', () {
      final result = filterService.filterFortunes(
        testFortunes,
        const FilterCriteria(),
      );
      expect(result, equals(testFortunes));
    });

    test('按運勢類型篩選', () {
      final result = filterService.filterFortunes(
        testFortunes,
        const FilterCriteria(fortuneType: FortuneType.overall),
      );
      expect(result.length, equals(1));
      expect(result.first.type, equals(FortuneType.overall));
    });

    test('按分數範圍篩選', () {
      final result = filterService.filterFortunes(
        testFortunes,
        const FilterCriteria(minScore: 70, maxScore: 90),
      );
      expect(result.length, equals(1));
      expect(result.first.score, equals(85));
    });

    test('按吉日篩選', () {
      final result = filterService.filterFortunes(
        testFortunes,
        const FilterCriteria(isLuckyDay: true),
      );
      expect(result.length, equals(1));
      expect(result.first.isLuckyDay, isTrue);
    });
  });

  group('FilterService - 排序測試', () {
    test('按日期升序排序', () {
      final result = filterService.sortFortunes(
        testFortunes,
        const FilterCriteria(
          sortField: SortField.date,
          sortOrder: SortOrder.ascending,
        ),
      );
      expect(result.first.date, equals(DateTime(2024, 1, 18)));
      expect(result.last.date, equals(DateTime(2024, 1, 19)));
    });

    test('按分數降序排序', () {
      final result = filterService.sortFortunes(
        testFortunes,
        const FilterCriteria(
          sortField: SortField.score,
          sortOrder: SortOrder.descending,
        ),
      );
      expect(result.first.score, equals(85));
      expect(result.last.score, equals(60));
    });
  });

  group('FilterService - 推薦測試', () {
    test('根據用戶歷史生成推薦', () {
      final userHistory = [
        Fortune(
          type: FortuneType.study,
          score: 75,
          date: DateTime(2024, 1, 17),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['考試', '讀書'],
          description: '適合學習',
        ),
      ];

      final result = filterService.generateRecommendations(
        testFortunes,
        userHistory,
      );
      
      // 驗證推薦結果是否按推薦分數排序
      expect(result.length, equals(testFortunes.length));
      expect(
        result.first.type,
        equals(FortuneType.study),
        reason: '應該優先推薦與用戶歷史相似的運勢類型',
      );
    });
  });
} 