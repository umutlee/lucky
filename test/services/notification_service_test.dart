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
      )).thenAnswer((_) async => true);
      when(mockNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidNotifications);
      when(mockAndroidNotifications.requestNotificationsPermission())
          .thenAnswer((_) async => true);

      await notificationService.initialize();

      verify(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
      verify(mockAndroidNotifications.requestNotificationsPermission()).called(1);
    });

    test('初始化失敗時應拋出異常', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => false);

      expect(
        () => notificationService.initialize(),
        throwsA(isA<NotificationException>()),
      );
    });
  });

  group('每日運勢通知測試', () {
    test('成功排程每日運勢通知', () async {
      final notifyTime = TimeOfDay.now();
      
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

    test('排程通知失敗時應拋出異常', () async {
      final notifyTime = TimeOfDay.now();
      
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

  group('通知管理測試', () {
    test('成功取消所有通知', () async {
      when(mockNotifications.cancelAll())
          .thenAnswer((_) async {});

      await notificationService.cancelAll();

      verify(mockNotifications.cancelAll()).called(1);
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

    test('排程過去時間的通知應被調整為明天', () async {
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
  });
} 