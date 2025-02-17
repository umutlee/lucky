import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/push_notification_service.dart';
import 'package:all_lucky/core/services/user_settings_service.dart';
import 'package:all_lucky/core/models/user_settings.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([UserSettingsService])
void main() {
  late PushNotificationService pushNotificationService;
  late MockUserSettingsService mockUserSettingsService;

  setUp(() {
    mockUserSettingsService = MockUserSettingsService();
    pushNotificationService = PushNotificationService(mockUserSettingsService);
  });

  group('推送通知服務測試', () {
    test('初始化測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => UserSettings.defaultSettings(),
      );

      final result = await pushNotificationService.initialize();
      expect(result, isTrue);
    });

    test('通知權限測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: true,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );

      final hasPermission = await pushNotificationService.requestPermission();
      expect(hasPermission, isTrue);
    });

    test('排程通知測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: true,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );

      final result = await pushNotificationService.scheduleDailyNotification();
      expect(result, isTrue);

      // 驗證通知是否已排程
      final scheduledNotifications = await pushNotificationService.getScheduledNotifications();
      expect(scheduledNotifications, isNotEmpty);
    });

    test('取消通知測試', () async {
      // 先排程一個通知
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: true,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );
      await pushNotificationService.scheduleDailyNotification();

      // 取消通知
      final result = await pushNotificationService.cancelAllNotifications();
      expect(result, isTrue);

      // 驗證通知是否已取消
      final scheduledNotifications = await pushNotificationService.getScheduledNotifications();
      expect(scheduledNotifications, isEmpty);
    });

    test('通知時間更新測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: true,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );

      // 更新通知時間
      final result = await pushNotificationService.updateNotificationTime('10:00');
      expect(result, isTrue);

      // 驗證設置是否已更新
      verify(mockUserSettingsService.updateNotificationTime('10:00')).called(1);
    });

    test('禁用通知測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: false,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );

      // 嘗試排程通知
      final result = await pushNotificationService.scheduleDailyNotification();
      expect(result, isFalse);

      // 驗證沒有排程通知
      final scheduledNotifications = await pushNotificationService.getScheduledNotifications();
      expect(scheduledNotifications, isEmpty);
    });

    test('通知內容測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: true,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );

      final notification = await pushNotificationService.createDailyNotification();
      
      expect(notification.title, contains('今日運勢'));
      expect(notification.body, isNotEmpty);
      expect(notification.payload, isNotNull);
    });

    test('錯誤處理測試', () async {
      when(mockUserSettingsService.getSettings()).thenThrow(Exception('測試錯誤'));

      // 初始化應該失敗但不拋出異常
      final result = await pushNotificationService.initialize();
      expect(result, isFalse);
    });

    test('通知點擊處理測試', () async {
      bool onNotificationClickCalled = false;
      
      pushNotificationService.setOnNotificationClick((payload) {
        onNotificationClickCalled = true;
      });

      // 模擬通知點擊
      await pushNotificationService.handleNotificationClick('test_payload');
      
      expect(onNotificationClickCalled, isTrue);
    });

    test('通知權限變更測試', () async {
      when(mockUserSettingsService.getSettings()).thenAnswer(
        (_) async => const UserSettings(
          notificationsEnabled: true,
          dailyNotification: true,
          notificationTime: '09:00',
        ),
      );

      // 初始化推送服務
      await pushNotificationService.initialize();

      // 模擬權限變更
      await pushNotificationService.onPermissionStatusChanged(false);

      // 驗證設置更新
      verify(mockUserSettingsService.updateNotificationPreference(false)).called(1);

      // 驗證通知已取消
      final scheduledNotifications = await pushNotificationService.getScheduledNotifications();
      expect(scheduledNotifications, isEmpty);
    });
  });
} 