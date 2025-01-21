import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/services/filter_service.dart';
import 'package:all_lucky/core/models/compass_direction.dart';

void main() {
  late FilterService filterService;
  late List<Fortune> testFortunes;

  setUp(() {
    filterService = FilterService();
    testFortunes = [
      Fortune(
        id: '1',
        type: '事業',
        title: '事業運勢',
        description: '今天的事業運勢不錯',
        score: 85,
        date: DateTime.now(),
        isLuckyDay: true,
      ),
      Fortune(
        id: '2',
        type: '學習',
        title: '學習運勢',
        description: '今天的學習運勢普通',
        score: 65,
        date: DateTime.now(),
        isLuckyDay: false,
      ),
      Fortune(
        id: '3',
        type: '財運',
        title: '財運運勢',
        description: '今天的財運運勢很好',
        score: 90,
        date: DateTime.now(),
        isLuckyDay: true,
      ),
    ];
  });

  group('過濾服務測試', () {
    test('按運勢類型過濾', () {
      final criteria = FilterCriteria(fortuneType: '事業');
      final filtered = filterService.filterFortunes(testFortunes, criteria);
      expect(filtered.length, 1);
      expect(filtered.first.type, '事業');
    });

    test('按分數範圍過濾', () {
      final criteria = FilterCriteria(minScore: 80, maxScore: 95);
      final filtered = filterService.filterFortunes(testFortunes, criteria);
      expect(filtered.length, 2);
      for (final fortune in filtered) {
        expect(fortune.score, inInclusiveRange(80, 95));
      }
    });

    test('按吉日過濾', () {
      final criteria = FilterCriteria(isLuckyDay: true);
      final filtered = filterService.filterFortunes(testFortunes, criteria);
      expect(filtered.length, 2);
      for (final fortune in filtered) {
        expect(fortune.isLuckyDay, isTrue);
      }
    });

    test('按方位過濾', () {
      final criteria = FilterCriteria(
        currentDirection: CompassDirection.north,
      );
      final filtered = filterService.filterFortunes(testFortunes, criteria);
      expect(filtered, isNotEmpty);
    });

    test('按分數排序', () {
      final criteria = FilterCriteria(
        sortField: SortField.score,
        sortOrder: SortOrder.descending,
      );
      final filtered = filterService.filterFortunes(testFortunes, criteria);
      expect(filtered.first.score, greaterThanOrEqualTo(filtered.last.score));
    });

    test('按日期排序', () {
      final criteria = FilterCriteria(
        sortField: SortField.date,
        sortOrder: SortOrder.ascending,
      );
      final filtered = filterService.filterFortunes(testFortunes, criteria);
      expect(filtered.first.date.isBefore(filtered.last.date) || 
             filtered.first.date.isAtSameMomentAs(filtered.last.date), isTrue);
    });
  });

  group('推薦算法測試', () {
    test('無用戶歷史時應按分數排序', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 80,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '今天運勢不錯',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 90,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '今天運勢很好',
        ),
      ];

      final recommendations = filterService.generateRecommendations(fortunes);
      expect(recommendations.first.score, 90);
      expect(recommendations.length, 2);
    });

    test('應根據用戶偏好生成推薦', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '適合學習',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 75,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '適合工作',
        ),
      ];

      final userHistory = [
        Fortune(
          type: FortuneType.daily,
          score: 90,
          date: DateTime.now().subtract(Duration(days: 1)),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '歷史記錄1',
        ),
      ];

      final recommendations = filterService.generateRecommendations(
        fortunes,
        userHistory: userHistory,
      );

      expect(recommendations.first.suitableActivities, contains('讀書'));
      expect(recommendations.length, 2);
    });
  });

  group('緩存功能測試', () {
    test('相同輸入應返回緩存結果', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '測試緩存',
        ),
      ];

      final firstResult = filterService.generateRecommendations(fortunes);
      final secondResult = filterService.generateRecommendations(fortunes);

      expect(identical(firstResult, secondResult), false); // 應該是不同的列表實例
      expect(firstResult.first.score, secondResult.first.score); // 但內容應該相同
    });

    test('不同輸入應生成新推薦', () {
      final fortunes1 = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '第一組',
        ),
      ];

      final fortunes2 = [
        Fortune(
          type: FortuneType.daily,
          score: 75,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '第二組',
        ),
      ];

      final result1 = filterService.generateRecommendations(fortunes1);
      final result2 = filterService.generateRecommendations(fortunes2);

      expect(result1.first.score, isNot(equals(result2.first.score)));
    });

    test('用戶歷史變化應生成新推薦', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '測試歷史',
        ),
      ];

      final history1 = [
        Fortune(
          type: FortuneType.daily,
          score: 90,
          date: DateTime.now().subtract(Duration(days: 1)),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '歷史1',
        ),
      ];

      final history2 = [
        Fortune(
          type: FortuneType.daily,
          score: 80,
          date: DateTime.now().subtract(Duration(days: 1)),
          isLuckyDay: true,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '歷史2',
        ),
      ];

      final result1 = filterService.generateRecommendations(
        fortunes,
        userHistory: history1,
      );
      final result2 = filterService.generateRecommendations(
        fortunes,
        userHistory: history2,
      );

      expect(identical(result1, result2), false);
    });
  });

  group('篩選功能測試', () {
    test('空篩選條件應返回所有運勢', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '測試1',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 75,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '測試2',
        ),
      ];

      final criteria = FilterCriteria();
      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered.length, equals(fortunes.length));
    });

    test('運勢類型篩選應正確過濾', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '每日運勢',
        ),
        Fortune(
          type: FortuneType.career,
          score: 75,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '事業運勢',
        ),
      ];

      final criteria = FilterCriteria(fortuneType: FortuneType.daily);
      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered.length, equals(1));
      expect(filtered.first.type, equals(FortuneType.daily));
    });

    test('分數範圍篩選應正確過濾', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '高分',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 65,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '低分',
        ),
      ];

      final criteria = FilterCriteria(minScore: 80, maxScore: 100);
      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered.length, equals(1));
      expect(filtered.first.score, equals(85));
    });
  });

  group('排序功能測試', () {
    test('按日期排序應正確', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now().add(Duration(days: 1)),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '明天',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 75,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '今天',
        ),
      ];

      final criteria = FilterCriteria(sortField: SortField.date, sortOrder: SortOrder.ascending);
      final sorted = filterService.sortFortunes(fortunes, criteria);
      expect(sorted.first.date, equals(DateTime.now()));
      expect(sorted.last.date, equals(DateTime.now().add(Duration(days: 1))));
    });

    test('按分數排序應正確', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 85,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東', '南'],
          suitableActivities: ['讀書', '運動'],
          description: '高分',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 75,
          date: DateTime.now(),
          isLuckyDay: false,
          luckyDirections: ['西', '北'],
          suitableActivities: ['工作', '旅行'],
          description: '低分',
        ),
      ];

      final criteria = FilterCriteria(sortField: SortField.score, sortOrder: SortOrder.descending);
      final sorted = filterService.sortFortunes(fortunes, criteria);
      expect(sorted.first.score, equals(85));
      expect(sorted.last.score, equals(75));
    });
  });

  group('邊界條件測試', () {
    test('空列表應返回空結果', () {
      final fortunes = <Fortune>[];
      final criteria = FilterCriteria();
      
      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered, isEmpty);
      
      final sorted = filterService.sortFortunes(fortunes, criteria);
      expect(sorted, isEmpty);
      
      final recommendations = filterService.generateRecommendations(fortunes);
      expect(recommendations, isEmpty);
    });

    test('極端分數範圍', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 0,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東'],
          suitableActivities: ['讀書'],
          description: '最低分',
        ),
        Fortune(
          type: FortuneType.daily,
          score: 100,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['南'],
          suitableActivities: ['運動'],
          description: '最高分',
        ),
      ];

      final criteria = FilterCriteria(minScore: 0, maxScore: 100);
      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered.length, equals(2));

      final criteriaLow = FilterCriteria(minScore: 0, maxScore: 0);
      final filteredLow = filterService.filterFortunes(fortunes, criteriaLow);
      expect(filteredLow.length, equals(1));
      expect(filteredLow.first.score, equals(0));

      final criteriaHigh = FilterCriteria(minScore: 100, maxScore: 100);
      final filteredHigh = filterService.filterFortunes(fortunes, criteriaHigh);
      expect(filteredHigh.length, equals(1));
      expect(filteredHigh.first.score, equals(100));
    });

    test('無效的日期範圍', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 80,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東'],
          suitableActivities: ['讀書'],
          description: '測試',
        ),
      ];

      final criteria = FilterCriteria(
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now(),
      );

      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered, isEmpty);
    });

    test('所有條件都不匹配', () {
      final fortunes = [
        Fortune(
          type: FortuneType.daily,
          score: 80,
          date: DateTime.now(),
          isLuckyDay: true,
          luckyDirections: ['東'],
          suitableActivities: ['讀書'],
          description: '測試',
        ),
      ];

      final criteria = FilterCriteria(
        fortuneType: FortuneType.career,
        minScore: 90,
        maxScore: 100,
        isLuckyDay: false,
        luckyDirections: ['西'],
        activities: ['運動'],
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
      );

      final filtered = filterService.filterFortunes(fortunes, criteria);
      expect(filtered, isEmpty);
    });
  });

  group('性能測試', () {
    test('大量數據篩選性能', () {
      final fortunes = List.generate(1000, (index) {
        return Fortune(
          type: index % 2 == 0 ? FortuneType.daily : FortuneType.career,
          score: (index % 100).toDouble(),
          date: DateTime.now().add(Duration(days: index % 30)),
          isLuckyDay: index % 2 == 0,
          luckyDirections: ['東', '南', '西', '北'][index % 4],
          suitableActivities: ['讀書', '運動', '工作', '旅行'][index % 4],
          description: '測試 $index',
        );
      });

      final startTime = DateTime.now();
      
      final criteria = FilterCriteria(
        fortuneType: FortuneType.daily,
        minScore: 50,
        maxScore: 80,
        isLuckyDay: true,
      );
      
      final filtered = filterService.filterFortunes(fortunes, criteria);
      final endTime = DateTime.now();
      
      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(100)); // 應在100毫秒內完成
      expect(filtered.length, greaterThan(0));
    });

    test('大量數據排序性能', () {
      final fortunes = List.generate(1000, (index) {
        return Fortune(
          type: FortuneType.daily,
          score: (index % 100).toDouble(),
          date: DateTime.now().add(Duration(days: index % 30)),
          isLuckyDay: index % 2 == 0,
          luckyDirections: ['東'],
          suitableActivities: ['讀書'],
          description: '測試 $index',
        );
      });

      final startTime = DateTime.now();
      
      final criteria = FilterCriteria(
        sortField: SortField.score,
        sortOrder: SortOrder.descending,
      );
      
      final sorted = filterService.sortFortunes(fortunes, criteria);
      final endTime = DateTime.now();
      
      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, lessThan(100)); // 應在100毫秒內完成
      expect(sorted.length, equals(fortunes.length));
      expect(sorted.first.score, greaterThanOrEqualTo(sorted.last.score));
    });

    test('緩存性能', () {
      final fortunes = List.generate(100, (index) {
        return Fortune(
          type: FortuneType.daily,
          score: (index % 100).toDouble(),
          date: DateTime.now().add(Duration(days: index % 30)),
          isLuckyDay: index % 2 == 0,
          luckyDirections: ['東'],
          suitableActivities: ['讀書'],
          description: '測試 $index',
        );
      });

      // 第一次調用，生成推薦
      final startTime1 = DateTime.now();
      final recommendations1 = filterService.generateRecommendations(fortunes);
      final duration1 = DateTime.now().difference(startTime1);

      // 第二次調用，應該使用緩存
      final startTime2 = DateTime.now();
      final recommendations2 = filterService.generateRecommendations(fortunes);
      final duration2 = DateTime.now().difference(startTime2);

      expect(duration2.inMilliseconds, lessThan(duration1.inMilliseconds));
      expect(recommendations1.length, equals(recommendations2.length));
    });
  });
} 