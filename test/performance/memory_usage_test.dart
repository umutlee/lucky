import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:all_lucky/app/app.dart';
import 'package:all_lucky/features/home/screens/home_screen.dart';
import 'package:all_lucky/features/fortune/screens/fortune_prediction_screen.dart';
import 'package:all_lucky/features/history/screens/history_screen.dart';
import 'dart:io';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'dart:async';

void main() {
  late VmService vmService;
  late IsolateRef mainIsolate;

  setUpAll(() async {
    // 連接到 VM 服務
    final uri = Platform.environment['VM_SERVICE_URL'];
    if (uri == null) {
      throw Exception('未設置 VM_SERVICE_URL 環境變量');
    }
    vmService = await vmServiceConnectUri(uri);
    final vm = await vmService.getVM();
    mainIsolate = vm.isolates!.first;
  });

  tearDownAll(() async {
    await vmService.dispose();
  });

  Future<int> getHeapSize() async {
    final memoryUsage = await vmService.getMemoryUsage(mainIsolate.id!);
    return memoryUsage.heapUsage;
  }

  Future<void> triggerGC() async {
    await vmService.getAllocationProfile(mainIsolate.id!);
  }

  group('內存使用測試', () {
    Future<int> getMemoryUsage() async {
      final processInfo = await Process.run('ps', ['-o', 'rss=', '-p', '${pid}']);
      return int.parse(processInfo.stdout.toString().trim());
    }

    testWidgets('應用啟動內存使用測試', (WidgetTester tester) async {
      final initialMemory = await getMemoryUsage();
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      final afterLaunchMemory = await getMemoryUsage();
      final memoryDiff = afterLaunchMemory - initialMemory;
      
      // 應用啟動後的內存增長不應超過 50MB
      expect(memoryDiff, lessThan(50 * 1024)); // 轉換為 KB
    });

    testWidgets('頁面切換內存泄漏測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      final initialMemory = await getMemoryUsage();
      
      // 多次切換頁面
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }
      
      final afterSwitchMemory = await getMemoryUsage();
      final memoryDiff = afterSwitchMemory - initialMemory;
      
      // 多次頁面切換後的內存增長不應超過 10MB
      expect(memoryDiff, lessThan(10 * 1024)); // 轉換為 KB
    });

    testWidgets('運勢預測內存使用測試', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FortunePredictionScreen()),
      );
      await tester.pumpAndSettle();
      
      final initialMemory = await getMemoryUsage();
      
      // 執行多次運勢預測
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        
        // 等待動畫完成
        await Future.delayed(const Duration(seconds: 2));
      }
      
      final afterPredictionMemory = await getMemoryUsage();
      final memoryDiff = afterPredictionMemory - initialMemory;
      
      // 多次運勢預測後的內存增長不應超過 20MB
      expect(memoryDiff, lessThan(20 * 1024)); // 轉換為 KB
    });

    testWidgets('歷史記錄列表內存使用測試', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HistoryScreen()),
      );
      await tester.pumpAndSettle();
      
      final initialMemory = await getMemoryUsage();
      
      // 滾動列表
      for (var i = 0; i < 50; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      
      final afterScrollMemory = await getMemoryUsage();
      final memoryDiff = afterScrollMemory - initialMemory;
      
      // 大量滾動後的內存增長不應超過 15MB
      expect(memoryDiff, lessThan(15 * 1024)); // 轉換為 KB
    });

    testWidgets('圖片緩存內存使用測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      final initialMemory = await getMemoryUsage();
      
      // 載入多張圖片
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.image));
        await tester.pumpAndSettle();
      }
      
      final afterImageLoadMemory = await getMemoryUsage();
      final memoryDiff = afterImageLoadMemory - initialMemory;
      
      // 載入多張圖片後的內存增長不應超過 30MB
      expect(memoryDiff, lessThan(30 * 1024)); // 轉換為 KB
    });

    testWidgets('內存回收測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      final initialMemory = await getMemoryUsage();
      
      // 執行一些內存密集型操作
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.image));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }
      
      // 強制垃圾回收
      await tester.binding.delayed(const Duration(seconds: 1));
      
      final afterGCMemory = await getMemoryUsage();
      final memoryDiff = afterGCMemory - initialMemory;
      
      // 垃圾回收後的內存增長不應超過 5MB
      expect(memoryDiff, lessThan(5 * 1024)); // 轉換為 KB
    });

    testWidgets('檢測記憶體洩漏', (WidgetTester tester) async {
      final initialMemory = await getHeapSize();
      
      // 模擬用戶反覆操作
      for (var i = 0; i < 100; i++) {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        
        // 切換到運勢預測頁面
        await tester.tap(find.byType(ElevatedButton).first);
        await tester.pumpAndSettle();
        
        // 返回首頁
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      
      // 觸發垃圾回收
      await triggerGC();
      
      final finalMemory = await getHeapSize();
      final memoryDiff = finalMemory - initialMemory;
      
      // 多次操作後，記憶體增長不應超過 10MB
      expect(memoryDiff, lessThan(10 * 1024 * 1024));
    });

    testWidgets('長時間運行穩定性測試', (WidgetTester tester) async {
      final initialMemory = await getHeapSize();
      final memoryReadings = <int>[];
      
      // 運行 5 分鐘
      for (var i = 0; i < 300; i++) {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        
        // 每秒記錄一次記憶體使用量
        memoryReadings.add(await getHeapSize());
        
        await Future.delayed(const Duration(seconds: 1));
      }
      
      // 計算記憶體使用趨勢
      final memoryTrend = memoryReadings.last - memoryReadings.first;
      
      // 長時間運行後，記憶體增長趨勢不應超過 20MB
      expect(memoryTrend, lessThan(20 * 1024 * 1024));
      
      // 檢查記憶體使用波動
      final maxMemory = memoryReadings.reduce((a, b) => a > b ? a : b);
      final minMemory = memoryReadings.reduce((a, b) => a < b ? a : b);
      final memoryFluctuation = maxMemory - minMemory;
      
      // 記憶體使用波動不應超過 30MB
      expect(memoryFluctuation, lessThan(30 * 1024 * 1024));
    });
  });
} 