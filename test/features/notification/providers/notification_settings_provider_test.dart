import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/features/notification/providers/notification_settings_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

@GenerateMocks([], customMocks: [
  MockSpec<NotificationService>(as: #MockNotificationSettingsService),
])
import 'notification_settings_provider_test.mocks.dart';

void main() {
  late NotificationSettingsNotifier notifier;
  late MockNotificationSettingsService mockService;
  late ProviderContainer container;

  setUp(() {
    tz.initializeTimeZones();
    mockService = MockNotificationSettingsService();
    container = ProviderContainer(
      overrides: [
        notificationSettingsProvider.overrideWith(
          (ref) => NotificationSettingsNotifier(service: mockService),
        ),
      ],
    );
    notifier = container.read(notificationSettingsProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationSettings', () {
    test('相同的設置應該相等', () {
      final time1 = DateTime(2024, 1, 1, 8, 0);
      final time2 = DateTime(2024, 1, 2, 8, 0); // 不同的日期但相同的時間

      final settings1 = NotificationSettings(
        isEnabled: true,
        isInitialized: true,
        notificationTime: time1,
      );

      final settings2 = NotificationSettings(
        isEnabled: true,
        isInitialized: true,
        notificationTime: time2,
      );

      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('不同的設置應該不相等', () {
      final time1 = DateTime(2024, 1, 1, 8, 0);
      final time2 = DateTime(2024, 1, 1, 9, 0); // 不同的時間

      final settings1 = NotificationSettings(
        isEnabled: true,
        isInitialized: true,
        notificationTime: time1,
      );

      final settings2 = NotificationSettings(
        isEnabled: true,
        isInitialized: true,
        notificationTime: time2,
      );

      expect(settings1, isNot(equals(settings2)));
    });

    test('toString 應該返回正確的格式', () {
      final settings = NotificationSettings(
        isEnabled: true,
        isInitialized: true,
        notificationTime: DateTime(2024, 1, 1, 8, 0),
      );

      expect(
        settings.toString(),
        'NotificationSettings(isEnabled: true, isInitialized: true, notificationTime: 8:00)',
      );
    });
  });

  group('NotificationSettingsNotifier', () {
    test('初始化成功時應該將狀態設為已啟用', () async {
      when(mockService.initialize()).thenAnswer((_) async => true);
      await notifier.initialize();
      
      final state = container.read(notificationSettingsProvider);
      expect(state.isEnabled, isTrue);
      expect(state.isInitialized, isTrue);
    });

    test('初始化失敗時應該將狀態設為未啟用', () async {
      when(mockService.initialize()).thenAnswer((_) async => false);
      await notifier.initialize();
      
      final state = container.read(notificationSettingsProvider);
      expect(state.isEnabled, isFalse);
      expect(state.isInitialized, isTrue);
    });

    test('初始化時發生異常應該將狀態設為未啟用', () async {
      when(mockService.initialize()).thenThrow(Exception('初始化失敗'));
      await notifier.initialize();
      
      final state = container.read(notificationSettingsProvider);
      expect(state.isEnabled, isFalse);
      expect(state.isInitialized, isTrue);
    });

    test('未初始化時不應該排程通知', () async {
      await notifier.scheduleNextNotification();
      verifyNever(mockService.scheduleFortuneNotification(any));
    });

    test('初始化成功後應該能夠排程通知', () async {
      final now = DateTime.now();
      final expectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        8,
        0,
      );
      
      when(mockService.initialize()).thenAnswer((_) async => true);
      when(mockService.scheduleFortuneNotification(any))
          .thenAnswer((_) async => true);
      
      await notifier.initialize();
      
      verify(mockService.scheduleFortuneNotification(
        argThat(
          predicate<DateTime>((time) =>
              time.hour == expectedTime.hour && time.minute == expectedTime.minute),
        ),
      )).called(1);
    });

    test('切換通知狀態應該正確執行', () async {
      when(mockService.initialize()).thenAnswer((_) async => true);
      when(mockService.cancelAllNotifications()).thenAnswer((_) async => true);
      when(mockService.scheduleFortuneNotification(any))
          .thenAnswer((_) async => true);
      
      await notifier.initialize();
      clearInteractions(mockService);

      // 切換到關閉狀態
      await notifier.toggleNotifications();
      verify(mockService.cancelAllNotifications()).called(1);
      expect(container.read(notificationSettingsProvider).isEnabled, isFalse);
      clearInteractions(mockService);

      // 切換到開啟狀態
      await notifier.toggleNotifications();
      verify(mockService.scheduleFortuneNotification(any)).called(1);
      expect(container.read(notificationSettingsProvider).isEnabled, isTrue);
    });

    test('更新通知時間應該重新排程通知', () async {
      when(mockService.initialize()).thenAnswer((_) async => true);
      when(mockService.cancelAllNotifications()).thenAnswer((_) async => true);
      when(mockService.scheduleFortuneNotification(any))
          .thenAnswer((_) async => true);
      
      await notifier.initialize();
      clearInteractions(mockService);
      
      final newTime = DateTime(2025, 1, 22, 8, 0);
      await notifier.updateNotificationTime(newTime);
      
      verifyInOrder([
        mockService.cancelAllNotifications(),
        mockService.scheduleFortuneNotification(
          argThat(
            predicate<DateTime>((time) =>
                time.hour == newTime.hour && time.minute == newTime.minute),
          ),
        ),
      ]);
      
      final state = container.read(notificationSettingsProvider);
      expect(state.notificationTime.hour, newTime.hour);
      expect(state.notificationTime.minute, newTime.minute);
    });

    test('更新通知時間失敗時不應該更新狀態', () async {
      when(mockService.initialize()).thenAnswer((_) async => true);
      when(mockService.cancelAllNotifications())
          .thenAnswer((_) async => false);
      when(mockService.scheduleFortuneNotification(any))
          .thenAnswer((_) async => true);
      
      await notifier.initialize();
      
      final originalState = container.read(notificationSettingsProvider);
      final newTime = DateTime(2025, 1, 22, 9, 0);
      
      await notifier.updateNotificationTime(newTime);
      
      final currentState = container.read(notificationSettingsProvider);
      expect(currentState, equals(originalState));
    });

    test('初始狀態應該有默認值', () {
      final state = container.read(notificationSettingsProvider);
      expect(state.isEnabled, isFalse);
      expect(state.isInitialized, isFalse);
      expect(state.notificationTime.hour, 8);
      expect(state.notificationTime.minute, 0);
    });

    test('排程下一次通知時應該考慮當前時間', () async {
      final now = DateTime(2024, 1, 1, 9, 0); // 固定時間進行測試
      final expectedTime = DateTime(2024, 1, 2, 8, 0); // 應該排程到下一天

      when(mockService.initialize()).thenAnswer((_) async => true);
      when(mockService.scheduleFortuneNotification(any))
          .thenAnswer((_) async => true);
      when(mockService.cancelAllNotifications())
          .thenAnswer((_) async => true);
      
      await notifier.initialize();
      clearInteractions(mockService);
      
      // 模擬當前時間
      await notifier.updateNotificationTime(DateTime(2024, 1, 1, 8, 0));
      clearInteractions(mockService);
      
      // 再次調用 scheduleNextNotification
      await notifier.scheduleNextNotification();
      
      verify(mockService.scheduleFortuneNotification(
        argThat(
          predicate<DateTime>((time) =>
              time.hour == expectedTime.hour && time.minute == expectedTime.minute),
        ),
      )).called(1);
    });
  });
} 