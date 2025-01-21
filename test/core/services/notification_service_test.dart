import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:all_lucky/core/services/notification_service.dart';

@GenerateMocks([], customMocks: [
  MockSpec<FlutterLocalNotificationsPlugin>(as: #MockNotificationsPlugin),
])
import 'notification_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  late MockNotificationsPlugin mockNotifications;
  late NotificationService notificationService;

  setUp(() {
    mockNotifications = MockNotificationsPlugin();
    notificationService = NotificationService(notifications: mockNotifications);

    when(mockNotifications.getNotificationAppLaunchDetails())
        .thenAnswer((_) async => NotificationAppLaunchDetails(
              didNotificationLaunchApp: false,
              notificationResponse: null,
            ));
  });

  group('NotificationService', () {
    test('初始化成功時應該返回 true', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => true);

      final success = await notificationService.initialize();
      expect(success, isTrue);
    });

    test('初始化失敗時應該返回 false', () async {
      when(mockNotifications.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => false);

      final success = await notificationService.initialize();
      expect(success, isFalse);
    });

    test('顯示通知成功時應該返回 true', () async {
      when(mockNotifications.show(
        any,
        any,
        any,
        any,
      )).thenAnswer((_) async {});

      final success = await notificationService.showFortuneNotification('今日運勢');
      expect(success, isTrue);
    });

    test('排程通知成功時應該返回 true', () async {
      when(mockNotifications.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            anyNamed('uiLocalNotificationDateInterpretation'),
      )).thenAnswer((_) async {});

      final success = await notificationService.scheduleFortuneNotification(
        tz.TZDateTime.now(tz.local).add(const Duration(days: 1)),
      );
      expect(success, isTrue);
    });

    test('取消所有通知成功時應該返回 true', () async {
      when(mockNotifications.cancelAll()).thenAnswer((_) async {});

      final success = await notificationService.cancelAllNotifications();
      expect(success, isTrue);
    });
  });
} 