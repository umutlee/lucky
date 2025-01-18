import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';

import 'package:all_lucky/core/services/notification_service.dart';
import 'notification_service_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  SharedPreferences
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidNotifications;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    mockAndroidNotifications = MockAndroidFlutterLocalNotificationsPlugin();
    mockPrefs = MockSharedPreferences();

    Get.put<SharedPreferences>(mockPrefs);

    notificationService = NotificationService();
    notificationService.testNotificationsPlugin = mockNotifications;
  });

  tearDown(() {
    Get.reset();
  });

  group('通知服務初始化測試', () {
    test('初始化成功', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse: anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => true);
      when(mockNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidNotifications);
      when(mockAndroidNotifications.requestNotificationsPermission())
          .thenAnswer((_) async => true);

      await notificationService.initialize();

      verify(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse: anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).called(1);
      verify(mockAndroidNotifications.requestNotificationsPermission()).called(1);
    });

    test('初始化失敗時應拋出異常', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse: anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => false);
      when(mockNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidNotifications);
      when(mockAndroidNotifications.requestNotificationsPermission())
          .thenAnswer((_) async => false);

      expect(
        () => notificationService.initialize(),
        throwsA(isA<NotificationException>()),
      );
    });
  });

  group('通知排程測試', () {
    test('每日運勢通知排程成功', () async {
      final notifyTime = TimeOfDay(hour: 9, minute: 0);
      
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      await notificationService.scheduleDailyFortuneNotification(notifyTime);

      verify(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('節氣提醒通知排程成功', () async {
      final solarTermDate = DateTime.now().add(Duration(days: 1));
      const termName = '立春';
      
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      await notificationService.scheduleSolarTermNotification(solarTermDate, termName);

      verify(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('吉日提醒通知排程成功', () async {
      final luckyDate = DateTime.now().add(Duration(days: 1));
      const description = '宜結婚';
      
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      await notificationService.scheduleLuckyDayNotification(luckyDate, description);

      verify(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('排程失敗時應拋出異常', () async {
      final notifyTime = TimeOfDay(hour: 9, minute: 0);
      
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      )).thenThrow(Exception('排程失敗'));

      expect(
        () => notificationService.scheduleDailyFortuneNotification(notifyTime),
        throwsA(isA<NotificationException>()),
      );
    });
  });

  group('取消通知測試', () {
    test('取消所有通知', () async {
      when(mockNotifications.cancelAll())
          .thenAnswer((_) async {});

      await notificationService.cancelAll();

      verify(mockNotifications.cancelAll()).called(1);
    });

    test('取消指定ID的通知', () async {
      const notificationId = 1;
      when(mockNotifications.cancel(notificationId))
          .thenAnswer((_) async {});

      await notificationService.cancelNotification(notificationId);

      verify(mockNotifications.cancel(notificationId)).called(1);
    });

    test('取消通知失敗時應拋出異常', () async {
      when(mockNotifications.cancelAll())
          .thenThrow(Exception('取消失敗'));

      expect(
        () => notificationService.cancelAll(),
        throwsA(isA<NotificationException>()),
      );
    });
  });

  group('獲取待處理通知測試', () {
    test('成功獲取待處理通知列表', () async {
      final mockRequests = [
        PendingNotificationRequest(
          id: 1,
          title: '測試通知1',
          body: '內容1',
          payload: 'payload1',
        ),
        PendingNotificationRequest(
          id: 2,
          title: '測試通知2',
          body: '內容2',
          payload: 'payload2',
        ),
      ];

      when(mockNotifications.pendingNotificationRequests())
          .thenAnswer((_) async => mockRequests);

      final requests = await notificationService.getPendingNotifications();

      expect(requests.length, equals(2));
      expect(requests.first.id, equals(1));
      expect(requests.last.id, equals(2));
    });

    test('獲取待處理通知失敗時應拋出異常', () async {
      when(mockNotifications.pendingNotificationRequests())
          .thenThrow(Exception('獲取失敗'));

      expect(
        () => notificationService.getPendingNotifications(),
        throwsA(isA<NotificationException>()),
      );
    });
  });

  group('邊界條件測試', () {
    test('重複初始化應正常處理', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);
      when(mockNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidNotifications);
      when(mockAndroidNotifications.requestNotificationsPermission())
          .thenAnswer((_) async => true);

      await notificationService.initialize();
      await notificationService.initialize(); // 重複初始化

      verify(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(2);
    });

    test('排程過去時間的通知應被忽略', () async {
      final pastTime = TimeOfDay.fromDateTime(
        DateTime.now().subtract(const Duration(hours: 1)),
      );

      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      await notificationService.scheduleDailyFortuneNotification(pastTime);

      verifyNever(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      ));
    });

    test('空的通知內容應被正確處理', () async {
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      final emptyDate = DateTime.now().add(const Duration(days: 1));
      await notificationService.scheduleSolarTermNotification(emptyDate, '');

      verify(mockNotifications.zonedSchedule(
        any,
        any,
        contains('節氣提醒'), // 應使用默認標題
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).called(1);
    });
  });

  group('錯誤處理測試', () {
    test('通知權限被拒絕時應拋出異常', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);
      when(mockNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidNotifications);
      when(mockAndroidNotifications.requestNotificationsPermission())
          .thenAnswer((_) async => false);

      expect(
        () => notificationService.initialize(),
        throwsA(
          isA<NotificationException>().having(
            (e) => e.code,
            'code',
            'PERMISSION_DENIED',
          ),
        ),
      );
    });

    test('無效的通知ID應被正確處理', () async {
      when(mockNotifications.cancel(any))
          .thenThrow(PlatformException(code: 'INVALID_ID'));

      expect(
        () => notificationService.cancelNotification(-1),
        throwsA(isA<NotificationException>()),
      );
    });

    test('通知調度失敗時應重試', () async {
      final notifyTime = TimeOfDay(hour: 9, minute: 0);
      var attempts = 0;

      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {
        attempts++;
        if (attempts == 1) {
          throw PlatformException(code: 'SCHEDULE_FAILED');
        }
      });

      await notificationService.scheduleDailyFortuneNotification(notifyTime);

      verify(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
        payload: anyNamed('payload'),
      )).called(2); // 應該嘗試兩次
    });

    test('無效的通知負載應被正確處理', () {
      final payload = '{invalid json}';

      expect(
        () => notificationService.onNotificationResponse(
          NotificationResponse(
            notificationResponseType: NotificationResponseType.selectedNotification,
            payload: payload,
          ),
        ),
        throwsA(isA<NotificationException>()),
      );
    });
  });
} 