import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/user_settings.dart';
import 'user_settings_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return PushNotificationService(notificationService);
});

/// 推送通知服務
class PushNotificationService {
  static const String _tag = 'PushNotificationService';
  final _logger = Logger(_tag);
  
  final UserSettingsService _userSettingsService;
  final NotificationService _notificationService;
  Function(String)? _onNotificationClick;
  
  PushNotificationService(this._userSettingsService) : 
    _notificationService = NotificationService();
  
  /// 初始化推送服務
  Future<bool> initialize() async {
    try {
      final settings = await _userSettingsService.getSettings();
      if (settings.notificationsEnabled) {
        await _notificationService.initialize();
        return true;
      }
      return false;
    } catch (e) {
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
      await _notificationService.subscribeToTopic(topic);
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
      await _notificationService.unsubscribeFromTopic(topic);
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
      return await _notificationService.getNotificationSettings();
    } catch (e, stackTrace) {
      _logger.error('獲取通知設置失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await _userSettingsService.getSettings();
      if (!settings.notificationsEnabled) return false;
      return await _notificationService.requestPermission();
    } catch (e) {
      return false;
    }
  }

  Future<bool> scheduleDailyNotification() async {
    try {
      final settings = await _userSettingsService.getSettings();
      if (!settings.notificationsEnabled || !settings.dailyNotification) {
        return false;
      }

      final notification = await createDailyNotification();
      await _notificationService.showNotification(
        id: 1,
        title: notification.title,
        body: notification.body,
        payload: notification.payload,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return await _notificationService.getScheduledNotifications();
  }

  Future<bool> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNotificationTime(String time) async {
    try {
      await _userSettingsService.updateNotificationTime(time);
      await cancelAllNotifications();
      if (await _userSettingsService.getSettings().then((s) => s.dailyNotification)) {
        await scheduleDailyNotification();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<NotificationData> createDailyNotification() async {
    return NotificationData(
      title: '今日運勢提醒',
      body: '點擊查看今日運勢詳情',
      payload: 'daily_fortune',
    );
  }

  void setOnNotificationClick(Function(String) callback) {
    _onNotificationClick = callback;
  }

  Future<void> handleNotificationClick(String payload) async {
    _onNotificationClick?.call(payload);
  }

  Future<void> onPermissionStatusChanged(bool granted) async {
    await _userSettingsService.updateNotificationPreference(granted);
    if (!granted) {
      await cancelAllNotifications();
    }
  }
}

class NotificationData {
  final String title;
  final String body;
  final String payload;

  NotificationData({
    required this.title,
    required this.body,
    required this.payload,
  });
}

/// 處理背景消息
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // 注意：此處不能使用任何依賴於上下文的功能
  print('收到背景消息: ${message.messageId}');
  
  // 可以存儲消息以供稍後處理
  // 或者使用 WorkManager 處理後台任務
} 