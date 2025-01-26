import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/services/notification_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return PushNotificationService(notificationService);
});

/// 推送通知服務
class PushNotificationService {
  static const String _tag = 'PushNotificationService';
  final _logger = Logger(_tag);
  
  final NotificationService _notificationService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  PushNotificationService(this._notificationService);
  
  /// 初始化推送服務
  Future<bool> initialize() async {
    try {
      // 初始化 Firebase
      await Firebase.initializeApp();
      
      // 請求通知權限
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        _logger.warning('用戶未授權推送通知');
        return false;
      }
      
      // 獲取 FCM Token
      final token = await _messaging.getToken();
      if (token != null) {
        _logger.info('FCM Token: $token');
        // TODO: 將 token 發送到後端服務器
      }
      
      // 監聽 token 刷新
      _messaging.onTokenRefresh.listen((newToken) {
        _logger.info('FCM Token 已更新: $newToken');
        // TODO: 將新 token 發送到後端服務器
      });
      
      // 設置消息處理器
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
      _logger.info('推送通知服務初始化成功');
      return true;
    } catch (e, stackTrace) {
      _logger.error('推送通知服務初始化失敗', e, stackTrace);
      return false;
    }
  }
  
  /// 處理前台消息
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      _logger.info('收到前台消息: ${message.messageId}');
      
      // 解析消息數據
      final data = message.data;
      final notification = message.notification;
      
      if (notification != null) {
        // 顯示本地通知
        await _notificationService.showNotification(
          title: notification.title ?? '新消息',
          body: notification.body ?? '',
          payload: jsonEncode(data),
        );
      }
    } catch (e, stackTrace) {
      _logger.error('處理前台消息失敗', e, stackTrace);
    }
  }
  
  /// 處理消息點擊事件
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    try {
      _logger.info('用戶點擊了通知: ${message.messageId}');
      
      // TODO: 處理通知點擊事件，例如導航到特定頁面
    } catch (e, stackTrace) {
      _logger.error('處理通知點擊失敗', e, stackTrace);
    }
  }
  
  /// 訂閱主題
  Future<bool> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.info('已訂閱主題: $topic');
      return true;
    } catch (e, stackTrace) {
      _logger.error('訂閱主題失敗: $topic', e, stackTrace);
      return false;
    }
  }
  
  /// 取消訂閱主題
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.info('已取消訂閱主題: $topic');
      return true;
    } catch (e, stackTrace) {
      _logger.error('取消訂閱主題失敗: $topic', e, stackTrace);
      return false;
    }
  }
  
  /// 獲取當前的通知設置
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _messaging.getNotificationSettings();
    } catch (e, stackTrace) {
      _logger.error('獲取通知設置失敗', e, stackTrace);
      rethrow;
    }
  }
}

/// 處理背景消息
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // 注意：此處不能使用任何依賴於上下文的功能
  print('收到背景消息: ${message.messageId}');
  
  // 可以存儲消息以供稍後處理
  // 或者使用 WorkManager 處理後台任務
} 