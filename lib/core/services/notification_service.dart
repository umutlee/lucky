import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../utils/logger.dart';

/// 通知服務提供者
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return NotificationServiceImpl(databaseHelper);
});

/// 通知類型
enum NotificationType {
  dailyFortune,    // 每日運勢
  luckyTime,       // 吉時提醒
  specialEvent,    // 特殊事件
  systemMessage,   // 系統消息
}

/// 通知服務基類
abstract class NotificationService {
  /// 初始化通知服務
  Future<bool> init();
  
  /// 請求通知權限
  Future<bool> requestPermission();
  
  /// 檢查通知權限
  Future<bool> checkPermission();
  
  /// 發送本地通知
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.systemMessage,
  });
  
  /// 發送定時通知
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.systemMessage,
  });
  
  /// 取消指定通知
  Future<void> cancelNotification(int id);
  
  /// 取消所有通知
  Future<void> cancelAllNotifications();
  
  /// 獲取 FCM Token
  Future<String?> getFCMToken();
  
  /// 設置每日運勢提醒
  Future<void> setDailyFortuneReminder(TimeOfDay time);
  
  /// 取消每日運勢提醒
  Future<void> cancelDailyFortuneReminder();
}

/// 通知服務實現
class NotificationServiceImpl implements NotificationService {
  static const String _tag = 'NotificationService';
  final _logger = Logger(_tag);
  
  final DatabaseHelper _databaseHelper;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _firebaseMessaging = FirebaseMessaging.instance;
  
  NotificationServiceImpl(this._databaseHelper);
  
  @override
  Future<bool> init() async {
    try {
      // 初始化時區數據
      tz.initializeTimeZones();
      
      // 初始化本地通知
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // 配置 Firebase Messaging
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // 處理後台消息
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 處理前台消息
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // 處理通知點擊
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
      
      return true;
    } catch (e, stackTrace) {
      _logger.error('初始化通知服務失敗', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<bool> requestPermission() async {
    try {
      // 請求本地通知權限
      final androidPermission = true; // Android 不需要請求權限
      final iosPermission = await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      
      // 請求 Firebase Messaging 權限
      final messaging = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      final hasPermission = androidPermission &&
          iosPermission &&
          messaging.authorizationStatus == AuthorizationStatus.authorized;
      
      // 保存權限狀態
      await _databaseHelper.update(
        'user_settings',
        {'notifications_enabled': hasPermission ? 1 : 0},
        where: 'id = 1',
      );
      
      return hasPermission;
    } catch (e, stackTrace) {
      _logger.error('請求通知權限失敗', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<bool> checkPermission() async {
    try {
      final results = await _databaseHelper.query(
        'user_settings',
        where: 'id = 1',
      );
      
      if (results.isEmpty) {
        return false;
      }
      
      return results.first['notifications_enabled'] == 1;
    } catch (e, stackTrace) {
      _logger.error('檢查通知權限失敗', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.systemMessage,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        '默認通知',
        channelDescription: '用於發送一般通知',
        importance: Importance.high,
        priority: Priority.high,
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
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e, stackTrace) {
      _logger.error('發送本地通知失敗', e, stackTrace);
    }
  }
  
  @override
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.systemMessage,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'scheduled_channel',
        '定時通知',
        channelDescription: '用於發送定時通知',
        importance: Importance.high,
        priority: Priority.high,
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
      
      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      return id;
    } catch (e, stackTrace) {
      _logger.error('排程通知失敗', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e, stackTrace) {
      _logger.error('取消通知失敗', e, stackTrace);
    }
  }
  
  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e, stackTrace) {
      _logger.error('取消所有通知失敗', e, stackTrace);
    }
  }
  
  @override
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e, stackTrace) {
      _logger.error('獲取 FCM Token 失敗', e, stackTrace);
      return null;
    }
  }
  
  @override
  Future<void> setDailyFortuneReminder(TimeOfDay time) async {
    try {
      // 取消現有的每日提醒
      await cancelDailyFortuneReminder();
      
      // 計算下一次提醒時間
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // 如果時間已過，設置為明天
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      // 設置新的提醒
      await scheduleNotification(
        title: '每日運勢提醒',
        body: '今天的運勢如何？點擊查看詳情',
        scheduledDate: scheduledDate,
        type: NotificationType.dailyFortune,
      );
      
      // 保存提醒時間
      await _databaseHelper.insert(
        'preferences',
        {
          'key': 'daily_fortune_reminder_time',
          'value': '${time.hour}:${time.minute}',
          'type': 'time',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      _logger.error('設置每日運勢提醒失敗', e, stackTrace);
    }
  }
  
  @override
  Future<void> cancelDailyFortuneReminder() async {
    try {
      // 刪除提醒時間設置
      await _databaseHelper.delete(
        'preferences',
        where: 'key = ?',
        whereArgs: ['daily_fortune_reminder_time'],
      );
      
      // 取消所有每日運勢提醒
      // 注意：這裡可能需要更精確的取消方式，
      // 目前是取消所有通知，實際應用中應該只取消特定類型的通知
      await cancelAllNotifications();
    } catch (e, stackTrace) {
      _logger.error('取消每日運勢提醒失敗', e, stackTrace);
    }
  }
  
  /// 處理通知點擊
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: 實現通知點擊處理邏輯
  }
  
  /// 處理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    showLocalNotification(
      title: message.notification?.title ?? '新消息',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }
  
  /// 處理通知點擊
  void _handleNotificationOpen(RemoteMessage message) {
    // TODO: 實現遠程通知點擊處理邏輯
  }
}

/// 處理後台消息
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // TODO: 實現後台消息處理邏輯
} 
} 