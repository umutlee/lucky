import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // 用於測試的 setter
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
      final type = data['type'] as String;
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
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        notifyTime.hour,
        notifyTime.minute,
      );

      final payload = json.encode({
        'type': 'daily_fortune',
        'route': '/daily-fortune',
        'date': scheduledDate.toIso8601String(),
      });

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        '每日運勢提醒',
        '今天的運勢已經準備好了，點擊查看詳情',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_fortune',
            '每日運勢',
            channelDescription: '每日運勢提醒通知',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      _logger.info('每日運勢通知排程成功');
    } catch (e) {
      _logger.error('排程每日運勢通知失敗: $e');
      throw NotificationException('排程每日運勢通知失敗: $e', 'SCHEDULE_ERROR');
    }
  }

  Future<void> scheduleSolarTermNotification(DateTime termDate, String termName) async {
    try {
      _logger.info('排程節氣提醒通知，日期: $termDate，節氣: $termName');
      
      final payload = json.encode({
        'type': 'solar_term',
        'route': '/solar-term',
        'date': termDate.toIso8601String(),
        'term': termName,
      });

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        '節氣提醒',
        '$termName即將到來，點擊查看詳情',
        tz.TZDateTime.from(termDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'solar_term',
            '節氣提醒',
            channelDescription: '節氣變化提醒通知',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      _logger.info('節氣提醒通知排程成功');
    } catch (e) {
      _logger.error('排程節氣提醒通知失敗: $e');
      throw NotificationException('排程節氣提醒通知失敗: $e', 'SCHEDULE_ERROR');
    }
  }

  Future<void> scheduleLuckyDayNotification(DateTime luckyDate, String description) async {
    try {
      _logger.info('排程吉日提醒通知，日期: $luckyDate，描述: $description');
      
      final payload = json.encode({
        'type': 'lucky_day',
        'route': '/lucky-day',
        'date': luckyDate.toIso8601String(),
        'description': description,
      });

      await flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        '吉日提醒',
        '明天是$description的好日子，點擊查看詳情',
        tz.TZDateTime.from(luckyDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lucky_day',
            '吉日提醒',
            channelDescription: '吉日提醒通知',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      _logger.info('吉日提醒通知排程成功');
    } catch (e) {
      _logger.error('排程吉日提醒通知失敗: $e');
      throw NotificationException('排程吉日提醒通知失敗: $e', 'SCHEDULE_ERROR');
    }
  }
} 