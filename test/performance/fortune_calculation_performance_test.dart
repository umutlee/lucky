import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/fortune_calculation_service.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'performance_test_framework.dart';

void main() {
  group('運勢計算性能測試', () {
    late ProviderContainer container;
    late FortuneCalculationService calculationService;

    setUp(() {
      container = ProviderContainer();
      calculationService = container.read(fortuneCalculationServiceProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('批量運勢計算性能測試', () async {
      final result = await PerformanceTestFramework.runTest(
        testName: '批量運勢計算',
        testFunction: () async {
          // 執行100次運勢計算
          for (var i = 0; i < 100; i++) {
            await calculationService.calculateFortune(
              type: FortuneType.daily,
              date: DateTime.now().add(Duration(days: i)),
              birthYear: 1990,
              zodiac: '龍',
            );
          }
        },
        metricsCollector: () => {
          'calculationCount': 100,
          'averageTime': 0, // TODO: 計算平均時間
        },
      );

      // 驗證性能指標
      expect(result.duration.inMilliseconds, lessThan(1000)); // 應在1秒內完成
      expect(result.memoryUsage, lessThan(10 * 1024 * 1024)); // 內存使用應小於10MB
    });

    test('並發運勢計算性能測試', () async {
      final result = await PerformanceTestFramework.runTest(
        testName: '並發運勢計算',
        testFunction: () async {
          // 創建10個並發計算任務
          final futures = List.generate(10, (index) {
            return Future.wait(
              List.generate(10, (i) {
                return calculationService.calculateFortune(
                  type: FortuneType.daily,
                  date: DateTime.now().add(Duration(days: i)),
                  birthYear: 1990,
                  zodiac: '龍',
                );
              }),
            );
          });

          // 等待所有任務完成
          await Future.wait(futures);
        },
        metricsCollector: () => {
          'concurrentTasks': 10,
          'calculationsPerTask': 10,
        },
      );

      // 驗證性能指標
      expect(result.duration.inMilliseconds, lessThan(2000)); // 應在2秒內完成
      expect(result.memoryUsage, lessThan(20 * 1024 * 1024)); // 內存使用應小於20MB
    });

    test('不同運勢類型計算性能比較', () async {
      final results = await Future.wait(
        FortuneType.values.map((type) {
          return PerformanceTestFramework.runTest(
            testName: '計算${type.name}運勢',
            testFunction: () async {
              // 執行50次特定類型的運勢計算
              for (var i = 0; i < 50; i++) {
                await calculationService.calculateFortune(
                  type: type,
                  date: DateTime.now().add(Duration(days: i)),
                  birthYear: 1990,
                  zodiac: '龍',
                );
              }
            },
            metricsCollector: () => {
              'fortuneType': type.name,
              'calculationCount': 50,
            },
          );
        }),
      );

      // 比較不同類型的性能
      for (final result in results) {
        expect(result.duration.inMilliseconds, lessThan(500)); // 每種類型應在500ms內完成
        expect(result.memoryUsage, lessThan(5 * 1024 * 1024)); // 每種類型內存使用應小於5MB
      }
    });

    test('緩存效果測試', () async {
      final date = DateTime.now();
      final type = FortuneType.daily;

      // 第一次計算（無緩存）
      final firstResult = await PerformanceTestFramework.runTest(
        testName: '首次運勢計算（無緩存）',
        testFunction: () async {
          await calculationService.calculateFortune(
            type: type,
            date: date,
            birthYear: 1990,
            zodiac: '龍',
          );
        },
      );

      // 第二次計算（應使用緩存）
      final secondResult = await PerformanceTestFramework.runTest(
        testName: '重複運勢計算（有緩存）',
        testFunction: () async {
          await calculationService.calculateFortune(
            type: type,
            date: date,
            birthYear: 1990,
            zodiac: '龍',
          );
        },
      );

      // 驗證緩存效果
      expect(
        secondResult.duration.inMilliseconds,
        lessThan(firstResult.duration.inMilliseconds ~/ 2),
        reason: '使用緩存後的計算時間應該顯著減少',
      );
    });
  });
} 