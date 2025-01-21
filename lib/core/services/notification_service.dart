import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final _logger = AppLogger();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @visibleForTesting
  set testNotificationsPlugin(FlutterLocalNotificationsPlugin plugin) {
    _notifications = plugin;
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      _logger.i('通知服務初始化成功');
      _isInitialized = true;
      return _isInitialized;
    } catch (e) {
      _logger.e('通知服務初始化失敗', e);
      rethrow;
    }
  }

  Future<bool> checkPermission() async {
    if (!_isInitialized) return false;

    try {
      final platform = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform == null) return false;

      final result = await platform.requestPermission();
      return result ?? false;
    } catch (e) {
      _logger.e('檢查通知權限失敗', e);
      return false;
    }
  }

  Future<void> showFortuneNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '接收每日運勢預測通知',
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

      await _notifications.show(
        0,
        title,
        body,
        details,
        payload: payload,
      );
      
      _logger.i('發送通知成功: $title');
    } catch (e) {
      _logger.e('發送通知失敗', e);
      rethrow;
    }
  }

  Future<void> scheduleFortuneNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'fortune_channel',
        '運勢通知',
        channelDescription: '接收每日運勢預測通知',
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

      await _notifications.zonedSchedule(
        0,
        title,
        body,
        scheduledDate,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      _logger.i('排程通知成功: $title, 時間: $scheduledDate');
    } catch (e) {
      _logger.e('排程通知失敗', e);
      rethrow;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];
    try {
      _logger.info('獲取待處理通知列表...');
      final notifications = await _notifications.pendingNotificationRequests();
      _logger.info('找到 ${notifications.length} 個待處理通知');
      return notifications;
    } catch (e, stack) {
      _logger.error('獲取待處理通知列表失敗', e, stack);
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    try {
      await _notifications.cancelAll();
      _logger.i('取消所有通知成功');
    } catch (e) {
      _logger.e('取消通知失敗', e);
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    try {
      await _notifications.cancel(id);
      _logger.info('已取消通知 $id');
    } catch (e, stack) {
      _logger.error('取消通知失敗', e, stack);
      rethrow;
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    _logger.info('點擊通知：${response.payload}');
    // TODO: 處理通知點擊事件
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // 處理背景通知點擊事件
  }
} 