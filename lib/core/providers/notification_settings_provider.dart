import 'dart:convert';
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

    return const NotificationSettings();
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      state = AsyncData(newSettings);

      await _prefs.setString(
        'notification_settings',
        const JsonEncoder().convert(newSettings.toJson()),
      );

      await _updateNotifications(newSettings);

      _logger.info('通知設置已更新');
    } catch (e) {
      _logger.error('更新通知設置時發生錯誤', e);
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _updateNotifications(NotificationSettings settings) async {
    try {
      await _notificationService.cancelAll();

      if (settings.enableDailyFortune) {
        await _notificationService.scheduleDailyFortuneNotification(
          settings.dailyNotificationTime,
        );
        _logger.info('已排程每日運勢通知');
      }

      _logger.info('通知已根據新設置更新');
    } catch (e) {
      _logger.error('更新通知時發生錯誤', e);
      rethrow;
    }
  }
} 