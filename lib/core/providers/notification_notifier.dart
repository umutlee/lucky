import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/sqlite_preferences_service.dart';
import '../utils/logger.dart';
import '../services/fortune_service.dart';
import '../services/solar_term_service.dart';
import '../services/notification_settings_service.dart';
import '../models/solar_term.dart';

/// 通知管理器提供者
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  final fortuneService = ref.watch(fortuneServiceProvider);
  final solarTermService = ref.watch(solarTermServiceProvider);
  final notificationSettings = ref.watch(notificationSettingsServiceProvider);
  return NotificationManager(
    fortuneService: fortuneService,
    solarTermService: solarTermService,
    notificationSettings: notificationSettings,
  );
});

/// 通知管理器
class NotificationManager {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final _logger = Logger('NotificationManager');
  final FortuneService _fortuneService;
  final SolarTermService _solarTermService;
  final NotificationSettingsService _settings;

  NotificationManager({
    required FortuneService fortuneService,
    required SolarTermService solarTermService,
    required NotificationSettingsService notificationSettings,
  }) : _fortuneService = fortuneService,
       _solarTermService = solarTermService,
       _settings = notificationSettings;

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
      
      if (initialized != null) {
        // 初始化成功後，根據設置排程通知
        await _initializeNotifications();
      }
      
      return initialized != null;
    } catch (e) {
      _logger.error('通知系統初始化失敗', e);
      return false;
    }
  }

  /// 初始化所有通知
  Future<void> _initializeNotifications() async {
    try {
      // 檢查每日運勢通知設置
      if (await _settings.isDailyFortuneEnabled()) {
        final time = await _settings.getDailyFortuneTime();
        if (time != null) {
          await scheduleDailyFortuneReminder(time: time);
        }
      }

      // 檢查節氣提醒設置
      if (await _settings.isSolarTermEnabled()) {
        await _scheduleNextSolarTermNotification();
      }
    } catch (e) {
      _logger.error('初始化通知失敗', e);
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

  /// 排程每日運勢提醒
  Future<void> scheduleDailyFortuneReminder({
    required DateTime time,
  }) async {
    try {
      // 檢查是否啟用
      if (!await _settings.isDailyFortuneEnabled()) {
        _logger.info('每日運勢提醒已禁用');
        return;
      }

      // 生成今日運勢
      final fortune = await _fortuneService.generateFortune('綜合');
      
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
        '今日運勢提醒',
        '今日運勢：${fortune.description}\n\n${fortune.recommendations.join('\n')}',
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

  /// 排程下一個節氣提醒
  Future<void> _scheduleNextSolarTermNotification() async {
    try {
      // 檢查是否啟用
      if (!await _settings.isSolarTermEnabled()) {
        _logger.info('節氣提醒已禁用');
        return;
      }

      final nextTerm = await _solarTermService.getNextTerm(DateTime.now());
      
      if (nextTerm != null) {
        await scheduleSolarTermNotification(
          time: nextTerm.date,
          solarTerm: nextTerm.name,
          description: nextTerm.description,
        );
      }
    } catch (e) {
      _logger.error('排程下一個節氣提醒失敗', e);
    }
  }

  /// 發送節氣提醒
  Future<void> scheduleSolarTermNotification({
    required DateTime time,
    required String solarTerm,
    required String description,
  }) async {
    try {
      // 檢查是否啟用
      if (!await _settings.isSolarTermEnabled()) {
        _logger.info('節氣提醒已禁用');
        return;
      }

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

  /// 更新每日運勢提醒時間
  Future<void> updateDailyFortuneTime(DateTime time) async {
    try {
      await _settings.setDailyFortuneTime(time);
      await scheduleDailyFortuneReminder(time: time);
      _logger.info('已更新每日運勢提醒時間：$time');
    } catch (e) {
      _logger.error('更新每日運勢提醒時間失敗', e);
    }
  }

  /// 設置每日運勢提醒狀態
  Future<void> setDailyFortuneEnabled(bool enabled) async {
    try {
      await _settings.setDailyFortuneEnabled(enabled);
      if (enabled) {
        final time = await _settings.getDailyFortuneTime();
        if (time != null) {
          await scheduleDailyFortuneReminder(time: time);
        }
      } else {
        await _notifications.cancel(0);
      }
      _logger.info('已${enabled ? '啟用' : '禁用'}每日運勢提醒');
    } catch (e) {
      _logger.error('設置每日運勢提醒狀態失敗', e);
    }
  }

  /// 設置節氣提醒狀態
  Future<void> setSolarTermEnabled(bool enabled) async {
    try {
      await _settings.setSolarTermEnabled(enabled);
      if (enabled) {
        await _scheduleNextSolarTermNotification();
      } else {
        await _notifications.cancel(1);
      }
      _logger.info('已${enabled ? '啟用' : '禁用'}節氣提醒');
    } catch (e) {
      _logger.error('設置節氣提醒狀態失敗', e);
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