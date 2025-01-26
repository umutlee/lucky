import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:all_lucky/core/services/push_notification_service.dart';

@GenerateMocks([], customMocks: [
  MockSpec<FirebaseMessaging>(as: #MockFirebaseMessaging),
])
import 'push_notification_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseMessaging mockMessaging;
  late PushNotificationService service;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    service = PushNotificationService(messaging: mockMessaging);
  });

  group('PushNotificationService', () {
    test('初始化成功時應該返回 true', () async {
      when(mockMessaging.getToken()).thenAnswer((_) async => 'test-token');
      when(mockMessaging.requestPermission()).thenAnswer(
        (_) async => const NotificationSettings(
          authorizationStatus: AuthorizationStatus.authorized,
        ),
      );

      final success = await service.initialize();
      expect(success, isTrue);
      verify(mockMessaging.getToken()).called(1);
      verify(mockMessaging.requestPermission()).called(1);
    });

    test('初始化失敗時應該返回 false', () async {
      when(mockMessaging.getToken()).thenThrow(Exception('獲取 token 失敗'));

      final success = await service.initialize();
      expect(success, isFalse);
    });

    test('訂閱主題成功時應該返回 true', () async {
      const topic = 'daily_fortune';
      when(mockMessaging.subscribeToTopic(topic)).thenAnswer((_) async {});

      final success = await service.subscribeToTopic(topic);
      expect(success, isTrue);
      verify(mockMessaging.subscribeToTopic(topic)).called(1);
    });

    test('取消訂閱主題成功時應該返回 true', () async {
      const topic = 'daily_fortune';
      when(mockMessaging.unsubscribeFromTopic(topic)).thenAnswer((_) async {});

      final success = await service.unsubscribeFromTopic(topic);
      expect(success, isTrue);
      verify(mockMessaging.unsubscribeFromTopic(topic)).called(1);
    });

    test('token 刷新時應該更新本地存儲', () async {
      const newToken = 'new-test-token';
      when(mockMessaging.onTokenRefresh).thenAnswer(
        (_) => Stream.value(newToken),
      );

      service.setupTokenRefreshListener();
      
      // 等待 token 刷新事件
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 驗證 token 是否被更新
      final currentToken = await service.getToken();
      expect(currentToken, equals(newToken));
    });

    test('接收前台消息時應該觸發回調', () async {
      final testMessage = RemoteMessage(
        messageId: 'test-id',
        notification: const RemoteNotification(
          title: '測試標題',
          body: '測試內容',
        ),
        data: const {
          'type': 'daily_fortune',
          'score': '85',
        },
      );

      bool callbackCalled = false;
      service.onMessageReceived = (message) {
        callbackCalled = true;
        expect(message.notification?.title, '測試標題');
        expect(message.notification?.body, '測試內容');
        expect(message.data['type'], 'daily_fortune');
        expect(message.data['score'], '85');
      };

      when(mockMessaging.onMessage).thenAnswer(
        (_) => Stream.value(testMessage),
      );

      service.setupMessageHandlers();
      
      // 等待消息處理
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(callbackCalled, isTrue);
    });

    test('處理後台消息時應該正確解析數據', () async {
      final testMessage = RemoteMessage(
        messageId: 'test-id',
        notification: const RemoteNotification(
          title: '測試標題',
          body: '測試內容',
        ),
        data: const {
          'type': 'daily_fortune',
          'score': '85',
        },
      );

      bool callbackCalled = false;
      service.onBackgroundMessage = (message) {
        callbackCalled = true;
        expect(message.notification?.title, '測試標題');
        expect(message.data['type'], 'daily_fortune');
      };

      // 模擬後台消息處理
      await service.handleBackgroundMessage(testMessage);
      
      expect(callbackCalled, isTrue);
    });
  });
} 