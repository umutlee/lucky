import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/sqlite_preferences_service.dart';
import '../utils/logger.dart';

/// 通知管理器提供者
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager();
});

/// 通知管理器
class NotificationManager {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final _logger = Logger('NotificationManager');

  /// 初始化通知
  Future<bool> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      final settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      final initialized = await _notifications.initialize(settings);
      _logger.info('通知系統初始化${initialized != null ? '成功' : '失敗'}');
      return initialized != null;
    } catch (e) {
      _logger.error('通知系統初始化失敗', e);
      return false;
    }
  }

  /// 檢查通知權限
  Future<bool> checkPermission() async {
    try {
      final status = await _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return status ?? false;
    } catch (e) {
      _logger.error('檢查通知權限失敗', e);
      return false;
    }
  }

  /// 發送每日運勢提醒
  Future<void> scheduleDailyFortune({
    required DateTime time,
    required String title,
    required String body,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'daily_fortune',
        '每日運勢',
        channelDescription: '每日運勢提醒',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.zonedSchedule(
        0,
        title,
        body,
        time.toLocal(),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      _logger.info('已排程每日運勢提醒：$time');
    } catch (e) {
      _logger.error('排程每日運勢提醒失敗', e);
    }
  }

  /// 發送節氣提醒
  Future<void> scheduleSolarTermNotification({
    required DateTime time,
    required String solarTerm,
    required String description,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'solar_term',
        '節氣提醒',
        channelDescription: '節氣變化提醒',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.zonedSchedule(
        1,
        '節氣：$solarTerm',
        description,
        time.toLocal(),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      _logger.info('已排程節氣提醒：$solarTerm - $time');
    } catch (e) {
      _logger.error('排程節氣提醒失敗', e);
    }
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      _logger.info('已取消所有通知');
    } catch (e) {
      _logger.error('取消通知失敗', e);
    }
  }
} 