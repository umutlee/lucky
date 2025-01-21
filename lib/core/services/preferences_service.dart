import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

class PreferencesService {
  static const String _keyDailyNotification = 'daily_notification';
  static const String _keyNotificationTime = 'notification_time';
  
  late final SharedPreferences _prefs;
  final _logger = Logger('PreferencesService');

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _logger.info('偏好設置服務初始化成功');
    } catch (e, stack) {
      _logger.error('偏好設置服務初始化失敗', e, stack);
      rethrow;
    }
  }

  Future<void> setDailyNotification(bool enabled) async {
    try {
      await _prefs.setBool(_keyDailyNotification, enabled);
      _logger.info('每日通知設置已更新: $enabled');
    } catch (e, stack) {
      _logger.error('設置每日通知失敗', e, stack);
      rethrow;
    }
  }

  Future<void> setNotificationTime(String time) async {
    try {
      await _prefs.setString(_keyNotificationTime, time);
      _logger.info('通知時間已更新: $time');
    } catch (e, stack) {
      _logger.error('設置通知時間失敗', e, stack);
      rethrow;
    }
  }

  bool getDailyNotification() {
    try {
      return _prefs.getBool(_keyDailyNotification) ?? true;
    } catch (e, stack) {
      _logger.error('獲取每日通知設置失敗', e, stack);
      return true;
    }
  }

  String getNotificationTime() {
    try {
      return _prefs.getString(_keyNotificationTime) ?? '08:00';
    } catch (e, stack) {
      _logger.error('獲取通知時間失敗', e, stack);
      return '08:00';
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
      _logger.info('偏好設置已清空');
    } catch (e, stack) {
      _logger.error('清空偏好設置失敗', e, stack);
      rethrow;
    }
  }
} 