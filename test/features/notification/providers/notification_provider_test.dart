import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/features/notification/providers/notification_provider.dart';

@GenerateMocks([NotificationService])
import 'notification_provider_test.mocks.dart';

void main() {
  late MockNotificationService mockService;
  late ProviderContainer container;

  setUp(() {
    mockService = MockNotificationService();
    container = ProviderContainer(
      overrides: [
        notificationProvider.overrideWith(
          (ref) => NotificationNotifier(service: mockService),
        ),
      ],
    );
  });

  test('初始化成功時應該將狀態設為 true', () async {
    when(mockService.initialize()).thenAnswer((_) async => true);
    when(mockService.showFortuneNotification(any)).thenAnswer((_) async {});
    when(mockService.scheduleFortuneNotification(any)).thenAnswer((_) async {});

    final notifier = container.read(notificationProvider.notifier);
    await notifier.initialize();

    final state = container.read(notificationProvider);
    expect(state, isTrue);
  });

  test('初始化失敗時應該將狀態設為 false', () async {
    when(mockService.initialize()).thenAnswer((_) async => false);

    final notifier = container.read(notificationProvider.notifier);
    await notifier.initialize();

    final state = container.read(notificationProvider);
    expect(state, isFalse);
  });

  test('未初始化時不應該顯示通知', () async {
    when(mockService.initialize()).thenAnswer((_) async => false);

    final notifier = container.read(notificationProvider.notifier);
    await notifier.initialize();
    await notifier.showFortuneNotification('測試通知');

    verifyNever(mockService.showFortuneNotification(any));
  });

  test('初始化成功後應該能夠顯示通知', () async {
    when(mockService.initialize()).thenAnswer((_) async => true);
    when(mockService.showFortuneNotification(any)).thenAnswer((_) async {});

    final notifier = container.read(notificationProvider.notifier);
    await notifier.initialize();
    await notifier.showFortuneNotification('測試通知');

    verify(mockService.showFortuneNotification(any)).called(1);
  });

  test('未初始化時不應該排程通知', () async {
    when(mockService.initialize()).thenAnswer((_) async => false);

    final notifier = container.read(notificationProvider.notifier);
    await notifier.initialize();
    await notifier.scheduleFortuneNotification(DateTime.now());

    verifyNever(mockService.scheduleFortuneNotification(any));
  });

  test('初始化成功後應該能夠排程通知', () async {
    when(mockService.initialize()).thenAnswer((_) async => true);
    when(mockService.scheduleFortuneNotification(any)).thenAnswer((_) async {});

    final notifier = container.read(notificationProvider.notifier);
    await notifier.initialize();
    await notifier.scheduleFortuneNotification(DateTime.now());

    verify(mockService.scheduleFortuneNotification(any)).called(1);
  });
} 