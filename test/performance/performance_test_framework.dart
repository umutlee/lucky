import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

/// 性能測試結果
class PerformanceTestResult {
  final String testName;
  final Duration duration;
  final int memoryUsage;
  final Map<String, dynamic> metrics;

  PerformanceTestResult({
    required this.testName,
    required this.duration,
    required this.memoryUsage,
    this.metrics = const {},
  });

  @override
  String toString() {
    return '''
性能測試結果: $testName
執行時間: ${duration.inMilliseconds}ms
內存使用: ${(memoryUsage / 1024 / 1024).toStringAsFixed(2)}MB
其他指標: $metrics
''';
  }
}

/// 性能測試框架
class PerformanceTestFramework {
  static final _logger = Logger('PerformanceTestFramework');
  static const _memoryThreshold = 50 * 1024 * 1024; // 50MB
  static const _timeThreshold = Duration(milliseconds: 100);

  /// 運行性能測試
  static Future<PerformanceTestResult> runTest({
    required String testName,
    required Future<void> Function() testFunction,
    Map<String, dynamic> Function()? metricsCollector,
  }) async {
    _logger.info('開始性能測試: $testName');

    // 記錄開始時間和內存使用
    final startTime = DateTime.now();
    final startMemory = _getCurrentMemoryUsage();

    // 執行測試
    await testFunction();

    // 記錄結束時間和內存使用
    final endTime = DateTime.now();
    final endMemory = _getCurrentMemoryUsage();

    // 計算結果
    final duration = endTime.difference(startTime);
    final memoryUsage = endMemory - startMemory;
    final metrics = metricsCollector?.call() ?? {};

    // 創建測試結果
    final result = PerformanceTestResult(
      testName: testName,
      duration: duration,
      memoryUsage: memoryUsage,
      metrics: metrics,
    );

    // 檢查性能指標
    _checkPerformance(result);

    _logger.info('性能測試完成: $testName\n$result');
    return result;
  }

  /// 運行 Widget 性能測試
  static Future<PerformanceTestResult> runWidgetTest({
    required String testName,
    required WidgetTester tester,
    required Widget widget,
    Future<void> Function(WidgetTester)? interactions,
  }) async {
    return runTest(
      testName: testName,
      testFunction: () async {
        // 構建和渲染 widget
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // 執行交互測試
        if (interactions != null) {
          await interactions(tester);
          await tester.pumpAndSettle();
        }
      },
      metricsCollector: () => {
        'frameCount': WidgetsBinding.instance.schedulerPhase.index,
        'renderCount': tester.binding.renderViewElement?.debugDoingBuild ?? 0,
      },
    );
  }

  /// 檢查性能指標
  static void _checkPerformance(PerformanceTestResult result) {
    if (result.duration > _timeThreshold) {
      _logger.warning(
        '${result.testName} 執行時間過長: ${result.duration.inMilliseconds}ms',
      );
    }

    if (result.memoryUsage > _memoryThreshold) {
      _logger.warning(
        '${result.testName} 內存使用過高: ${(result.memoryUsage / 1024 / 1024).toStringAsFixed(2)}MB',
      );
    }
  }

  /// 獲取當前內存使用量
  static int _getCurrentMemoryUsage() {
    // TODO: 實現更準確的內存使用量計算
    return 0;
  }
}

/// 性能測試輔助方法
extension PerformanceTestExtension on WidgetTester {
  /// 測量 widget 構建時間
  Future<Duration> measureBuildTime(Widget widget) async {
    final startTime = DateTime.now();
    await pumpWidget(widget);
    await pumpAndSettle();
    return DateTime.now().difference(startTime);
  }

  /// 測量幀率
  Future<double> measureFrameRate(
    Widget widget,
    Future<void> Function(WidgetTester) interactions,
  ) async {
    await pumpWidget(widget);
    await pumpAndSettle();

    final startTime = DateTime.now();
    int frameCount = 0;

    // 記錄幀數
    final subscription = WidgetsBinding.instance.addPersistentFrameCallback((_) {
      frameCount++;
    });

    // 執行交互
    await interactions(this);
    await pumpAndSettle();

    // 取消監聽
    subscription.dispose();

    // 計算幀率
    final duration = DateTime.now().difference(startTime);
    return frameCount / duration.inSeconds;
  }
} 