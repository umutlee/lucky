import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../services/sqlite_preferences_service.dart';

final notificationSettingsNotifierProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings>>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return NotificationSettingsNotifier(prefsService);
});

class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  final SQLitePreferencesService _prefsService;

  NotificationSettingsNotifier(this._prefsService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final enabled = await _prefsService.getValue<bool>('notifications_enabled') ?? true;
      final timeStr = await _prefsService.getValue<String>('notification_time') ?? '08:00';
      final timeParts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      final enableSolarTerm = await _prefsService.getValue<bool>('solar_term_enabled') ?? true;
      final solarTermDays = await _prefsService.getValue<int>('solar_term_days') ?? 1;
      final enableLuckyDay = await _prefsService.getValue<bool>('lucky_day_enabled') ?? true;

      state = AsyncValue.data(NotificationSettings(
        enableDailyFortune: enabled,
        dailyNotificationTime: time,
        enableSolarTerm: enableSolarTerm,
        solarTermPreNotifyDuration: Duration(days: solarTermDays),
        enableLuckyDay: enableLuckyDay,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      await _prefsService.setValue('notifications_enabled', newSettings.enableDailyFortune);
      await _prefsService.setValue(
        'notification_time',
        '${newSettings.dailyNotificationTime.hour.toString().padLeft(2, '0')}:'
        '${newSettings.dailyNotificationTime.minute.toString().padLeft(2, '0')}',
      );
      await _prefsService.setValue('solar_term_enabled', newSettings.enableSolarTerm);
      await _prefsService.setValue('solar_term_days', newSettings.solarTermPreNotifyDuration.inDays);
      await _prefsService.setValue('lucky_day_enabled', newSettings.enableLuckyDay);
      
      state = AsyncValue.data(newSettings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetSettings() async {
    try {
      final defaultSettings = NotificationSettings();
      await updateSettings(defaultSettings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
} 