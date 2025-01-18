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
} 