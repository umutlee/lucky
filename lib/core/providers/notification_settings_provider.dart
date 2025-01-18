import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

part 'notification_settings_provider.g.dart';

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  final _logger = Logger('NotificationSettingsNotifier');
  late final SharedPreferences _prefs;
  late final NotificationService _notificationService;

  @override
  Future<NotificationSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    _notificationService = NotificationService();
    await _notificationService.initialize();

    // 從 SharedPreferences 讀取設置
    final settingsJson = _prefs.getString('notification_settings');
    if (settingsJson != null) {
      try {
        return NotificationSettings.fromJson(
          Map<String, dynamic>.from(
            const JsonDecoder().convert(settingsJson),
          ),
        );
      } catch (e) {
        _logger.error('解析通知設置時發生錯誤', e);
      }
    }

    // 返回默認設置
    return const NotificationSettings();
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      // 更新狀態
      state = AsyncData(newSettings);

      // 保存到 SharedPreferences
      await _prefs.setString(
        'notification_settings',
        const JsonEncoder().convert(newSettings.toJson()),
      );

      // 根據新設置更新通知
      await _updateNotifications(newSettings);

      _logger.info('通知設置已更新');
    } catch (e) {
      _logger.error('更新通知設置時發生錯誤', e);
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _updateNotifications(NotificationSettings settings) async {
    try {
      // 先取消所有通知
      await _notificationService.cancelAllNotifications();

      // 如果啟用了每日運勢通知
      if (settings.enableDailyFortune) {
        final now = DateTime.now();
        final scheduleTime = DateTime(
          now.year,
          now.month,
          now.day,
          settings.dailyNotificationTime.hour,
          settings.dailyNotificationTime.minute,
        );

        // 如果今天的通知時間已過，設置為明天
        final finalScheduleTime = scheduleTime.isBefore(now)
            ? scheduleTime.add(const Duration(days: 1))
            : scheduleTime;

        await _notificationService.scheduleDailyFortuneNotification(
          scheduleTime: finalScheduleTime,
          title: '每日運勢提醒',
          body: '今日運勢已更新，點擊查看詳情',
          payload: 'daily_fortune',
        );
      }

      // 如果啟用了節氣提醒，這裡需要獲取下一個節氣
      if (settings.enableSolarTerm) {
        // TODO: 實現獲取下一個節氣的邏輯
        // final nextTerm = await getNextSolarTerm();
        // await _notificationService.scheduleSolarTermNotification(
        //   termDate: nextTerm.date,
        //   termName: nextTerm.name,
        //   preNotifyDuration: settings.solarTermPreNotifyDuration,
        // );
      }

      _logger.info('通知已根據新設置更新');
    } catch (e) {
      _logger.error('更新通知時發生錯誤', e);
      rethrow;
    }
  }

  Future<void> resetSettings() async {
    await updateSettings(const NotificationSettings());
  }
} 