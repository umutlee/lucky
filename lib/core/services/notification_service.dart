import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications;

  NotificationService({FlutterLocalNotificationsPlugin? notifications})
      : notifications = notifications ?? FlutterLocalNotificationsPlugin();

  Future<bool> initialize() async {
    try {
      tz.initializeTimeZones();
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      
      final initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      final result = await notifications.initialize(initializationSettings);
      if (result == true) {
        AppLogger.i('通知服務初始化成功');
        return true;
      } else {
        AppLogger.e('通知服務初始化失敗');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.e('通知服務初始化失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> checkPermission() async {
    if (!await _isInitialized()) return false;

    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      AppLogger.e('檢查通知權限失敗', e);
      return false;
    }
  }

  Future<void> showFortuneNotification(String message) async {
    try {
      if (!await _isInitialized()) {
        AppLogger.w('通知服務未初始化');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '顯示每日運勢預測的通知',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await notifications.show(
        0,
        '今日運勢',
        message,
        details,
      );

      AppLogger.i('運勢通知發送成功');
    } catch (e, stackTrace) {
      AppLogger.e('發送運勢通知失敗', e, stackTrace);
    }
  }

  Future<void> scheduleFortuneNotification(DateTime scheduledDate) async {
    try {
      if (!await _isInitialized()) {
        AppLogger.w('通知服務未初始化');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '顯示每日運勢預測的通知',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await notifications.zonedSchedule(
        0,
        '今日運勢',
        '點擊查看今日運勢預測',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      AppLogger.i('運勢通知排程成功: ${scheduledDate.toString()}');
    } catch (e, stackTrace) {
      AppLogger.e('排程運勢通知失敗', e, stackTrace);
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!await _isInitialized()) return [];
    try {
      AppLogger.i('獲取待處理通知列表...');
      final pendingNotifications = await notifications.pendingNotificationRequests();
      AppLogger.i('找到 ${pendingNotifications.length} 個待處理通知');
      return pendingNotifications;
    } catch (e, stackTrace) {
      AppLogger.e('獲取待處理通知失敗', e, stackTrace);
      return [];
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await notifications.cancelAll();
      AppLogger.i('已取消所有通知');
    } catch (e, stackTrace) {
      AppLogger.e('取消通知失敗', e, stackTrace);
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!await _isInitialized()) return;
    try {
      await notifications.cancel(id);
      AppLogger.i('已取消通知 $id');
    } catch (e, stack) {
      AppLogger.e('取消通知失敗', e, stack);
      rethrow;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.i('通知被點擊: ${response.payload}');
    // TODO: 處理通知點擊事件
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // 處理背景通知點擊事件
  }

  Future<bool> _isInitialized() async {
    final platform = await notifications.getNotificationAppLaunchDetails();
    return platform != null;
  }
} 