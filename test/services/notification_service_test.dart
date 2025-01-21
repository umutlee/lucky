import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:all_lucky/core/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;

  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService();
    notificationService.plugin = mockNotifications;
  });

  group('通知服務測試', () {
    test('初始化成功', () async {
      when(mockNotifications.initialize(any))
          .thenAnswer((_) async => true);

      final result = await notificationService.initialize();
      expect(result, isTrue);
    });

    test('初始化失敗', () async {
      when(mockNotifications.initialize(any))
          .thenAnswer((_) async => false);

      final result = await notificationService.initialize();
      expect(result, isFalse);
    });

    test('檢查權限', () async {
      when(mockNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(AndroidFlutterLocalNotificationsPlugin());

      final result = await notificationService.checkPermission();
      expect(result, isTrue);
    });

    test('排程通知', () async {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(days: 1));
      
      await notificationService.scheduleNotification(
        id: 1,
        title: '測試通知',
        body: '這是一個測試通知',
        scheduledDate: scheduledDate,
      );

      verify(mockNotifications.zonedSchedule(
        1,
        '測試通知',
        '這是一個測試通知',
        scheduledDate,
        any,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      )).called(1);
    });

    test('獲取待處理通知', () async {
      final mockRequests = [
        const PendingNotificationRequest(
          id: 1,
          title: '測試通知',
          body: '這是一個測試通知',
          payload: null,
        ),
      ];

      when(mockNotifications.pendingNotificationRequests())
          .thenAnswer((_) async => mockRequests);

      final requests = await notificationService.getPendingNotifications();
      expect(requests, isNotEmpty);
      expect(requests.first.id, 1);
      expect(requests.first.title, '測試通知');
    });
  });
} 