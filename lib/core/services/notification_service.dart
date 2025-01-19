import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import '../utils/logger.dart';

class NotificationException implements Exception {
  final String message;
  final String code;

  NotificationException(this.message, this.code);

  @override
  String toString() => 'NotificationException: [$code] $message';
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _logger = Logger('NotificationService');
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  set testNotificationsPlugin(FlutterLocalNotificationsPlugin plugin) {
    flutterLocalNotificationsPlugin = plugin;
  }

  Future<void> initialize() async {
    try {
      _logger.info('初始化通知服務...');
      tz.initializeTimeZones();

      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      final success = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (success != true) {
        throw NotificationException('通知初始化失敗', 'INIT_FAILED');
      }

      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation == null) {
        throw NotificationException('無法獲取 Android 通知實現', 'NO_ANDROID_IMPL');
      }

      final permissionGranted = await androidImplementation.requestNotificationsPermission();
      if (permissionGranted != true) {
        throw NotificationException('通知權限請求被拒絕', 'PERMISSION_DENIED');
      }

      _logger.info('通知服務初始化完成');
    } catch (e) {
      _logger.error('通知服務初始化失敗: $e');
      throw NotificationException('通知服務初始化失敗: $e', 'INIT_ERROR');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    try {
      _logger.info('收到通知點擊: ${response.payload}');
      if (response.payload == null) {
        _logger.warning('通知沒有包含 payload');
        return;
      }

      final data = json.decode(response.payload!) as Map<String, dynamic>;
      final route = data['route'] as String;

      Get.toNamed(route, arguments: data);
    } catch (e) {
      _logger.error('處理通知點擊時發生錯誤: $e');
      Get.snackbar(
        '錯誤',
        '無法處理通知點擊',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> scheduleDailyFortuneNotification(TimeOfDay notifyTime) async {
    try {
      _logger.info('排程每日運勢通知，時間: ${notifyTime.hour}:${notifyTime.minute}');
      
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        notifyTime.hour,
        notifyTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        _logger.info('通知時間已過，設置為明天: $scheduledDate');
      }

      final payload = json.encode({
        'type': 'daily_fortune',
        'route': '/daily-fortune',
        'date': scheduledDate.toIso8601String(),
      });

      await _scheduleNotification(
        id: 0,
        title: '每日運勢提醒',
        body: '今天的運勢已經準備好了，點擊查看詳情',
        scheduledDate: scheduledDate,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logger.info('每日運勢通知排程成功');
    } catch (e) {
      _logger.error('排程每日運勢通知失敗: $e');
      throw NotificationException('排程每日運勢通知失敗: $e', 'SCHEDULE_ERROR');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    var attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'fortune_reminder',
              '運勢提醒',
              channelDescription: '運勢相關的提醒通知',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchDateTimeComponents,
          payload: payload,
        );
        break;
      } catch (e) {
        attempts++;
        _logger.warning('排程通知失敗，嘗試次數: $attempts');
        if (attempts == maxAttempts) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  Future<void> cancelAll() async {
    try {
      _logger.info('取消所有通知...');
      await flutterLocalNotificationsPlugin.cancelAll();
      _logger.info('所有通知已取消');
    } catch (e) {
      _logger.error('取消通知時發生錯誤: $e');
      throw NotificationException('取消通知失敗: $e', 'CANCEL_ERROR');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      _logger.info('獲取待處理通知列表...');
      final notifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      _logger.info('找到 ${notifications.length} 個待處理通知');
      return notifications;
    } catch (e) {
      _logger.error('獲取待處理通知列表時發生錯誤: $e');
      throw NotificationException('獲取待處理通知列表失敗: $e', 'GET_PENDING_ERROR');
    }
  }
} 