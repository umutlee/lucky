import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:all_lucky/core/services/notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;

  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService();
  });

  group('NotificationService Tests', () {
    test('initialize should setup notifications correctly', () async {
      // Arrange
      when(mockNotifications.initialize(any))
          .thenAnswer((_) async => true);

      // Act
      await notificationService.initialize();

      // Assert
      verify(mockNotifications.initialize(any)).called(1);
    });

    test('showFortuneNotification should show notification', () async {
      // Arrange
      const title = '今日運勢';
      const body = '今天是個好日子！';
      
      when(mockNotifications.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      // Act
      await notificationService.showFortuneNotification(
        title: title,
        body: body,
      );

      // Assert
      verify(mockNotifications.show(
        any,
        title,
        body,
        any,
        payload: null,
      )).called(1);
    });

    test('scheduleFortuneNotification should schedule notification', () async {
      // Arrange
      const title = '明日運勢提醒';
      const body = '別忘了查看明天的運勢！';
      final scheduledDate = DateTime.now().add(const Duration(days: 1));
      
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
        uiLocalNotificationDateInterpretation:
            anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      // Act
      await notificationService.scheduleFortuneNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      // Assert
      verify(mockNotifications.zonedSchedule(
        any,
        title,
        body,
        any,
        any,
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