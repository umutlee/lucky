import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static const String _tag = 'NotificationService';
  final _logger = Logger(_tag);
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    try {
      final initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
      final initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          // Handle iOS foreground notification
        },
      );
      
      final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      final success = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );
      
      if (success ?? false) {
        _isInitialized = true;
        _logger.info('通知服務初始化成功');
        return true;
      } else {
        _logger.error('通知服務初始化失敗');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('通知服務初始化失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> _requestPermission() async {
    try {
      final platform = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform != null) {
        final granted = await platform.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      _logger.error('檢查通知權限失敗', e);
      return false;
    }
  }

  /// 顯示一般通知
  Future<bool> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'default',
    String channelName = '一般通知',
    String channelDescription = '應用通知',
    NotificationDetails? details,
  }) async {
    if (!_isInitialized) {
      _logger.warning('通知服務未初始化');
      return false;
    }

    try {
      final androidDetails = details?.android ?? AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      final iosDetails = details?.iOS ?? DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 2147483647,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      _logger.info('通知發送成功');
      return true;
    } catch (e, stackTrace) {
      _logger.error('發送通知失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> showFortuneNotification(String message) async {
    if (!_isInitialized) {
      _logger.warning('通知服務未初始化');
      return false;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '每日運勢提醒',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
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

      await _notifications.show(
        0,
        '今日運勢',
        message,
        details,
        payload: 'fortune_notification',
      );

      _logger.info('運勢通知發送成功');
      return true;
    } catch (e, stackTrace) {
      _logger.error('發送運勢通知失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> scheduleFortuneNotification(DateTime scheduledDate) async {
    if (!_isInitialized) {
      _logger.warning('通知服務未初始化');
      return false;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '每日運勢提醒',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
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

      await _notifications.zonedSchedule(
        0,
        '今日運勢',
        '點擊查看今日運勢預測',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'fortune_notification',
      );

      _logger.info('運勢通知排程成功: ${scheduledDate.toString()}');
      return true;
    } catch (e, stackTrace) {
      _logger.error('排程運勢通知失敗', e, stackTrace);
      return false;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      _logger.info('獲取待處理通知列表...');
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      _logger.info('找到 ${pendingNotifications.length} 個待處理通知');
      return pendingNotifications;
    } catch (e, stackTrace) {
      _logger.error('獲取待處理通知失敗', e, stackTrace);
      return [];
    }
  }

  Future<bool> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.info('已取消所有通知');
      return true;
    } catch (e, stackTrace) {
      _logger.error('取消通知失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      _logger.info('已取消通知 $id');
      return true;
    } catch (e, stack) {
      _logger.error('取消通知失敗', e, stack);
      return false;
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _logger.info('通知被點擊: ${response.payload}');
    // TODO: 處理通知點擊事件
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // 處理背景通知點擊事件
  }
} 