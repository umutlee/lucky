import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final _logger = Logger('NotificationService');
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @visibleForTesting
  set testNotificationsPlugin(FlutterLocalNotificationsPlugin plugin) {
    _notifications = plugin;
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      _isInitialized = await _notifications.initialize(initializationSettings) ?? false;
      _logger.info('通知服務初始化成功');
      return _isInitialized;
    } catch (e) {
      _logger.error('通知服務初始化失敗', e);
      return false;
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
      _logger.error('檢查通知權限失敗', e);
      return false;
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    if (!_isInitialized) return;

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'lucky_app_channel',
            '運勢通知',
            channelDescription: '每日運勢提醒',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      _logger.info('已排程通知：${scheduledDate.toString()}');
    } catch (e) {
      _logger.error('排程通知失敗', e);
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
      _logger.info('已取消所有通知');
    } catch (e, stack) {
      _logger.error('取消通知失敗', e, stack);
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