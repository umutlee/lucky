import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sqlite_preferences_service.dart';
import '../utils/logger.dart';

/// 通知設置服務提供者
final notificationSettingsServiceProvider = Provider<NotificationSettingsService>((ref) {
  final preferencesService = ref.watch(sqlitePreferencesServiceProvider);
  return NotificationSettingsService(preferencesService);
});

/// 通知設置服務
class NotificationSettingsService {
  final SqlitePreferencesService _preferences;
  final _logger = Logger('NotificationSettingsService');

  static const String _keyDailyFortuneEnabled = 'notification_daily_fortune_enabled';
  static const String _keySolarTermEnabled = 'notification_solar_term_enabled';
  static const String _keyDailyFortuneTime = 'notification_daily_fortune_time';

  NotificationSettingsService(this._preferences);

  /// 獲取每日運勢通知狀態
  Future<bool> isDailyFortuneEnabled() async {
    try {
      return await _preferences.getBool(_keyDailyFortuneEnabled) ?? true;
    } catch (e) {
      _logger.error('獲取每日運勢通知狀態失敗', e);
      return true;
    }
  }

  /// 設置每日運勢通知狀態
  Future<void> setDailyFortuneEnabled(bool enabled) async {
    try {
      await _preferences.setBool(_keyDailyFortuneEnabled, enabled);
      _logger.info('設置每日運勢通知狀態：$enabled');
    } catch (e) {
      _logger.error('設置每日運勢通知狀態失敗', e);
    }
  }

  /// 獲取節氣提醒通知狀態
  Future<bool> isSolarTermEnabled() async {
    try {
      return await _preferences.getBool(_keySolarTermEnabled) ?? true;
    } catch (e) {
      _logger.error('獲取節氣提醒通知狀態失敗', e);
      return true;
    }
  }

  /// 設置節氣提醒通知狀態
  Future<void> setSolarTermEnabled(bool enabled) async {
    try {
      await _preferences.setBool(_keySolarTermEnabled, enabled);
      _logger.info('設置節氣提醒通知狀態：$enabled');
    } catch (e) {
      _logger.error('設置節氣提醒通知狀態失敗', e);
    }
  }

  /// 獲取每日運勢提醒時間
  Future<DateTime?> getDailyFortuneTime() async {
    try {
      final timeString = await _preferences.getString(_keyDailyFortuneTime);
      if (timeString != null) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          final now = DateTime.now();
          return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      }
      // 默認早上 8:00
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 8, 0);
    } catch (e) {
      _logger.error('獲取每日運勢提醒時間失敗', e);
      return null;
    }
  }

  /// 設置每日運勢提醒時間
  Future<void> setDailyFortuneTime(DateTime time) async {
    try {
      final timeString = '${time.hour}:${time.minute}';
      await _preferences.setString(_keyDailyFortuneTime, timeString);
      _logger.info('設置每日運勢提醒時間：$timeString');
    } catch (e) {
      _logger.error('設置每日運勢提醒時間失敗', e);
    }
  }
} 