import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/features/notification/providers/notification_provider.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late NotificationNotifier notificationNotifier;
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();
    notificationNotifier = NotificationNotifier();
  });

  group('NotificationNotifier Tests', () {
    test('initial state should be false', () {
      expect(notificationNotifier.state, false);
    });

    test('initialize should set state to true on success', () async {
      // Arrange
      when(mockService.initialize())
          .thenAnswer((_) async {});

      // Act
      await notificationNotifier.initialize();

      // Assert
      expect(notificationNotifier.state, true);
      verify(mockService.initialize()).called(1);
    });

    test('initialize should set state to false on error', () async {
      // Arrange
      when(mockService.initialize())
          .thenThrow(Exception('初始化失敗'));

      // Act
      await notificationNotifier.initialize();

      // Assert
      expect(notificationNotifier.state, false);
      verify(mockService.initialize()).called(1);
    });

    test('scheduleFortuneNotification should not call service when state is false',
        () async {
      // Arrange
      final scheduledDate = DateTime.now();

      // Act
      await notificationNotifier.scheduleFortuneNotification(
        title: '測試標題',
        body: '測試內容',
        scheduledDate: scheduledDate,
      );

      // Assert
      verifyNever(mockService.scheduleFortuneNotification(
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
      ));
    });

    test('showFortuneNotification should not call service when state is false',
        () async {
      // Act
      await notificationNotifier.showFortuneNotification(
        title: '測試標題',
        body: '測試內容',
      );

      // Assert
      verifyNever(mockService.showFortuneNotification(
        title: anyNamed('title'),
        body: anyNamed('body'),
      ));
    });

    test('cancelAllNotifications should not call service when state is false',
        () async {
      // Act
      await notificationNotifier.cancelAllNotifications();

      // Assert
      verifyNever(mockService.cancelAllNotifications());
    });

    test(
        'scheduleFortuneNotification should call service and not throw when state is true',
        () async {
      // Arrange
      notificationNotifier = NotificationNotifier();
      await notificationNotifier.initialize();
      final scheduledDate = DateTime.now();

      when(mockService.scheduleFortuneNotification(
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
      )).thenAnswer((_) async {});

      // Act & Assert
      expect(
        () => notificationNotifier.scheduleFortuneNotification(
          title: '測試標題',
          body: '測試內容',
          scheduledDate: scheduledDate,
        ),
        returnsNormally,
      );
    });
  });
} 