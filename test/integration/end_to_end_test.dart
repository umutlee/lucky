import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:all_lucky/app/app.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/core/services/fortune_service.dart';
import 'package:all_lucky/core/services/user_settings_service.dart';
import 'package:all_lucky/core/services/push_notification_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  NotificationService,
  FortuneService,
  UserSettingsService,
  PushNotificationService,
])
import 'end_to_end_test.mocks.dart';

void main() {
  late MockNotificationService notificationService;
  late MockFortuneService fortuneService;
  late MockUserSettingsService userSettingsService;
  late MockPushNotificationService pushNotificationService;

  setUp(() {
    notificationService = MockNotificationService();
    fortuneService = MockFortuneService();
    userSettingsService = MockUserSettingsService();
    pushNotificationService = MockPushNotificationService();
  });

  group('端到端測試 - 核心用戶流程', () {
    testWidgets('首次啟動流程測試', (WidgetTester tester) async {
      // 模擬首次啟動
      when(userSettingsService.isFirstLaunch()).thenReturn(true);
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 驗證是否顯示歡迎頁面
      expect(find.text('歡迎使用運勢APP'), findsOneWidget);
      
      // 填寫用戶信息
      await tester.enterText(find.byType(TextField).first, '測試用戶');
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      
      // 選擇生肖和星座
      await tester.tap(find.text('龍'));
      await tester.tap(find.text('金牛座'));
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();
      
      // 驗證是否進入主頁
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('每日運勢查詢流程測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 點擊運勢查詢按鈕
      await tester.tap(find.byIcon(Icons.fortune));
      await tester.pumpAndSettle();
      
      // 等待運勢計算
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      
      // 驗證運勢結果顯示
      expect(find.byType(FortuneCard), findsOneWidget);
      expect(find.text('今日運勢'), findsOneWidget);
    });

    testWidgets('通知設置流程測試', (WidgetTester tester) async {
      when(notificationService.requestPermission())
          .thenAnswer((_) async => true);
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 進入設置頁面
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      // 開啟通知
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      
      // 驗證權限請求
      verify(notificationService.requestPermission()).called(1);
      
      // 設置提醒時間
      await tester.tap(find.text('設置提醒時間'));
      await tester.pumpAndSettle();
      
      // 選擇時間
      await tester.tap(find.text('確定'));
      await tester.pumpAndSettle();
      
      // 驗證設置是否保存
      verify(userSettingsService.saveNotificationSettings(any)).called(1);
    });

    testWidgets('運勢歷史記錄查看流程測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 進入歷史記錄頁面
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      
      // 驗證歷史記錄列表
      expect(find.byType(ListView), findsOneWidget);
      
      // 點擊歷史記錄項目
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      
      // 驗證詳情頁面
      expect(find.byType(FortuneDetailScreen), findsOneWidget);
    });

    testWidgets('錯誤處理流程測試', (WidgetTester tester) async {
      // 模擬網絡錯誤
      when(fortuneService.getDailyFortune())
          .thenThrow(Exception('網絡連接失敗'));
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 嘗試查詢運勢
      await tester.tap(find.byIcon(Icons.fortune));
      await tester.pumpAndSettle();
      
      // 驗證錯誤提示
      expect(find.text('網絡連接失敗'), findsOneWidget);
      expect(find.text('重試'), findsOneWidget);
      
      // 點擊重試
      await tester.tap(find.text('重試'));
      await tester.pumpAndSettle();
      
      // 驗證重試請求
      verify(fortuneService.getDailyFortune()).called(2);
    });

    testWidgets('數據同步流程測試', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 進入設置頁面
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      // 點擊同步按鈕
      await tester.tap(find.text('同步數據'));
      await tester.pumpAndSettle();
      
      // 驗證同步進度顯示
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      
      // 驗證同步完成提示
      expect(find.text('同步完成'), findsOneWidget);
    });

    testWidgets('推送通知功能測試', (WidgetTester tester) async {
      when(pushNotificationService.requestPermission())
          .thenAnswer((_) async => true);
      when(pushNotificationService.getToken())
          .thenAnswer((_) async => 'test_token');
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 進入通知設置頁面
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      
      // 開啟推送通知
      await tester.tap(find.text('開啟推送通知'));
      await tester.pumpAndSettle();
      
      // 驗證權限請求
      verify(pushNotificationService.requestPermission()).called(1);
      
      // 驗證 token 獲取
      verify(pushNotificationService.getToken()).called(1);
      
      // 模擬收到推送通知
      await pushNotificationService.onMessageReceived({
        'title': '今日運勢提醒',
        'body': '您的幸運時刻即將到來',
      });
      await tester.pumpAndSettle();
      
      // 驗證通知顯示
      expect(find.text('今日運勢提醒'), findsOneWidget);
      expect(find.text('您的幸運時刻即將到來'), findsOneWidget);
      
      // 點擊通知
      await tester.tap(find.text('今日運勢提醒'));
      await tester.pumpAndSettle();
      
      // 驗證是否跳轉到相應頁面
      expect(find.byType(FortunePredictionScreen), findsOneWidget);
    });

    testWidgets('推送通知權限拒絕處理測試', (WidgetTester tester) async {
      when(pushNotificationService.requestPermission())
          .thenAnswer((_) async => false);
      
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 進入通知設置頁面
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      
      // 嘗試開啟推送通知
      await tester.tap(find.text('開啟推送通知'));
      await tester.pumpAndSettle();
      
      // 驗證權限拒絕提示
      expect(find.text('需要通知權限'), findsOneWidget);
      expect(find.text('請在系統設置中開啟通知權限'), findsOneWidget);
      
      // 點擊去設置按鈕
      await tester.tap(find.text('去設置'));
      await tester.pumpAndSettle();
      
      // 驗證是否調用系統設置
      verify(pushNotificationService.openSettings()).called(1);
    });
  });
} 