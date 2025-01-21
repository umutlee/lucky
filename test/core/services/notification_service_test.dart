import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:all_lucky/core/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService();
    notificationService.testNotificationsPlugin = mockNotifications;
  });

  group('NotificationService Tests', () {
    test('initialize should setup notifications correctly', () async {
      // Arrange
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      when(mockNotifications.initialize(initSettings))
          .thenAnswer((_) async => true);

      // Act
      final result = await notificationService.initialize();

      // Assert
      expect(result, true);
      verify(mockNotifications.initialize(initSettings)).called(1);
    });

    test('showFortuneNotification should show notification', () async {
      // Arrange
      const title = '今日運勢';
      const body = '今天是個好日子！';
      
      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '接收每日運勢預測通知',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      when(mockNotifications.show(
        0,
        title,
        body,
        details,
        payload: null,
      )).thenAnswer((_) async {});

      // Act
      await notificationService.showFortuneNotification(
        title: title,
        body: body,
      );

      // Assert
      verify(mockNotifications.show(
        0,
        title,
        body,
        details,
        payload: null,
      )).called(1);
    });

    test('scheduleFortuneNotification should schedule notification', () async {
      // Arrange
      const title = '明日運勢提醒';
      const body = '別忘了查看明天的運勢！';
      final scheduledDate = DateTime.now().add(const Duration(days: 1));
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      
      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '接收每日運勢預測通知',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      when(mockNotifications.zonedSchedule(
        0,
        title,
        body,
        tzDateTime,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: null,
      )).thenAnswer((_) async {});

      // Act
      await notificationService.scheduleFortuneNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      // Assert
      verify(mockNotifications.zonedSchedule(
        0,
        title,
        body,
        tzDateTime,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: null,
      )).called(1);
    });

    test('cancelAllNotifications should cancel all notifications', () async {
      // Arrange
      when(mockNotifications.cancelAll())
          .thenAnswer((_) async {});

      // Act
      await notificationService.cancelAllNotifications();

      // Assert
      verify(mockNotifications.cancelAll()).called(1);
    });
  });
} 