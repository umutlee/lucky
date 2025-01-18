import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/core/models/fortune.dart';
import '../../lib/core/models/compass_direction.dart';
import '../../lib/core/services/fortune_direction_service.dart';
import '../../lib/core/services/compass_service.dart';

void main() {
  group('Fortune Direction Integration Tests', () {
    late ProviderContainer container;
    late FortuneDirectionService fortuneDirectionService;
    late CompassService compassService;

    setUp(() {
      container = ProviderContainer();
      fortuneDirectionService = container.read(fortuneDirectionProvider);
      compassService = CompassService();
    });

    tearDown(() {
      container.dispose();
    });

    test('Integration test for fortune and direction services', () {
      // 創建測試運勢數據
      final fortune = Fortune(
        id: '1',
        type: '學習',
        score: 85,
        description: '今天適合學習',
        recommendations: ['閱讀', '寫作'],
        date: DateTime.now(),
      );

      // 獲取吉利方位
      final luckyDirections = fortuneDirectionService.getLuckyDirections(fortune);
      
      // 驗證吉利方位
      expect(luckyDirections, contains('東')); // 學習方位必須包含東方
      expect(luckyDirections.length, 3); // 根據分數85應該有3個吉利方位

      // 測試不同方位的建議
      final directions = [
        CompassDirection.fromDegrees(90), // 東
        CompassDirection.fromDegrees(180), // 南
        CompassDirection.fromDegrees(270), // 西
        CompassDirection.fromDegrees(0), // 北
      ];

      for (final direction in directions) {
        final advice = fortuneDirectionService.getDirectionAdvice(
          fortune,
          direction,
        );

        if (luckyDirections.contains(direction.direction)) {
          expect(advice, contains('適合'));
        } else {
          expect(advice, contains('建議') || contains('避免'));
        }
      }
    });

    test('Integration test for time-based recommendations', () {
      final fortune = Fortune(
        id: '1',
        type: '學習',
        score: 75,
        description: '今天適合學習',
        recommendations: ['閱讀', '寫作'],
        date: DateTime.now(),
      );

      // 測試不同時間的建議
      final testTimes = [
        DateTime(2024, 1, 1, 7), // 早上7點
        DateTime(2024, 1, 1, 13), // 下午1點
        DateTime(2024, 1, 1, 20), // 晚上8點
      ];

      for (final time in testTimes) {
        final currentDirection = CompassDirection.fromDegrees(90); // 東
        final advice = fortuneDirectionService.getFullDirectionAdvice(
          fortune,
          currentDirection,
          time,
        );

        if (time.hour >= 6 && time.hour < 12) {
          expect(advice, contains('好時機'));
        } else {
          expect(advice, contains('建議稍後'));
        }
      }
    });

    test('Integration test for compass service with fortune directions', () {
      final fortune = Fortune(
        id: '1',
        type: '事業',
        score: 95,
        description: '今天事業運勢極佳',
        recommendations: ['談判', '簽約'],
        date: DateTime.now(),
      );

      final luckyDirections = fortuneDirectionService.getLuckyDirections(fortune);
      
      // 測試最近吉利方位計算
      final testDirections = [
        CompassDirection.fromDegrees(60), // 接近東方
        CompassDirection.fromDegrees(150), // 接近南方
        CompassDirection.fromDegrees(240), // 接近西方
        CompassDirection.fromDegrees(330), // 接近北方
      ];

      for (final direction in testDirections) {
        final nearest = compassService.getNearestLuckyDirection(
          direction,
          luckyDirections,
        );

        expect(nearest, isNotNull);
        expect(luckyDirections, contains(nearest!.direction));
      }
    });

    test('Integration test for different fortune types', () {
      final testCases = [
        (type: '學習', score: 85, expectedDirection: '東'),
        (type: '事業', score: 85, expectedDirection: '南'),
        (type: '財運', score: 85, expectedDirection: '西'),
        (type: '人際', score: 85, expectedDirection: '北'),
      ];

      for (final testCase in testCases) {
        final fortune = Fortune(
          id: '1',
          type: testCase.type,
          score: testCase.score,
          description: '測試運勢',
          recommendations: ['測試'],
          date: DateTime.now(),
        );

        final luckyDirections = fortuneDirectionService.getLuckyDirections(fortune);
        expect(luckyDirections, contains(testCase.expectedDirection));
      }
    });
  });
} 