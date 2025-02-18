import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../models/zodiac.dart';
import '../utils/logger.dart';

/// 用戶設置服務提供者
final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  return UserSettingsService();
});

/// 用戶設置服務
class UserSettingsService {
  final Logger _logger = Logger('UserSettingsService');
  UserSettings? _cachedSettings;
  static const String _settingsKey = 'user_settings';

  /// 獲取用戶設置
  Future<UserSettings> getSettings() async {
    try {
      if (_cachedSettings != null) {
        return _cachedSettings!;
      }

      // 模擬從本地存儲加載設置
      await Future.delayed(const Duration(milliseconds: 500));
      _cachedSettings = UserSettings.defaultSettings();
      return _cachedSettings!;
    } catch (e, stack) {
      _logger.error('獲取用戶設置失敗', e, stack);
      rethrow;
    }
  }

  /// 更新用戶設置
  Future<void> updateSettings(UserSettings settings) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _cachedSettings = settings;
      _logger.info('更新用戶設置成功');
    } catch (e, stack) {
      _logger.error('更新用戶設置失敗', e, stack);
      rethrow;
    }
  }

  /// 啟用通知
  Future<void> enableNotifications(bool enabled) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(hasEnabledNotifications: enabled);
      await updateSettings(newSettings);
      _logger.info('${enabled ? '啟用' : '禁用'}通知成功');
    } catch (e, stack) {
      _logger.error('${enabled ? '啟用' : '禁用'}通知失敗', e, stack);
      rethrow;
    }
  }

  /// 設置通知時間
  Future<void> setNotificationTime(String time) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(notificationTime: time);
      await updateSettings(newSettings);
      _logger.info('設置通知時間成功: $time');
    } catch (e, stack) {
      _logger.error('設置通知時間失敗', e, stack);
      rethrow;
    }
  }

  /// 設置位置權限
  Future<void> setLocationPermission(bool granted) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(hasLocationPermission: granted);
      await updateSettings(newSettings);
      _logger.info('設置位置權限成功: ${granted ? '已授權' : '未授權'}');
    } catch (e, stack) {
      _logger.error('設置位置權限失敗', e, stack);
      rethrow;
    }
  }

  /// 完成引導
  Future<void> completeOnboarding() async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(
        hasCompletedOnboarding: true,
        isFirstLaunch: false,
      );
      await updateSettings(newSettings);
      _logger.info('完成引導成功');
    } catch (e, stack) {
      _logger.error('完成引導失敗', e, stack);
      rethrow;
    }
  }

  /// 接受條款
  Future<void> acceptTerms() async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(hasAcceptedTerms: true);
      await updateSettings(newSettings);
      _logger.info('接受條款成功');
    } catch (e, stack) {
      _logger.error('接受條款失敗', e, stack);
      rethrow;
    }
  }

  /// 接受隱私政策
  Future<void> acceptPrivacy() async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(hasAcceptedPrivacy: true);
      await updateSettings(newSettings);
      _logger.info('接受隱私政策成功');
    } catch (e, stack) {
      _logger.error('接受隱私政策失敗', e, stack);
      rethrow;
    }
  }

  /// 設置語言
  Future<void> setLocale(String locale) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(locale: locale);
      await updateSettings(newSettings);
      _logger.info('設置語言成功: $locale');
    } catch (e, stack) {
      _logger.error('設置語言失敗', e, stack);
      rethrow;
    }
  }

  /// 設置主題模式
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(themeMode: mode);
      await updateSettings(newSettings);
      _logger.info('設置主題模式成功: ${mode.toString()}');
    } catch (e, stack) {
      _logger.error('設置主題模式失敗', e, stack);
      rethrow;
    }
  }

  /// 設置自動備份
  Future<void> setAutoBackup(bool enabled) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(autoBackupEnabled: enabled);
      await updateSettings(newSettings);
      _logger.info('設置自動備份成功: ${enabled ? '啟用' : '禁用'}');
    } catch (e, stack) {
      _logger.error('設置自動備份失敗', e, stack);
      rethrow;
    }
  }

  /// 設置每日通知
  Future<void> setDailyNotification(bool enabled) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(dailyNotification: enabled);
      await updateSettings(newSettings);
      _logger.info('設置每日通知成功: ${enabled ? '啟用' : '禁用'}');
    } catch (e, stack) {
      _logger.error('設置每日通知失敗', e, stack);
      rethrow;
    }
  }

  /// 更新通知偏好
  Future<void> updateNotificationPreference(bool enabled) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(notificationsEnabled: enabled);
      await updateSettings(newSettings);
      _logger.info('更新通知偏好成功: ${enabled ? '啟用' : '禁用'}');
    } catch (e, stack) {
      _logger.error('更新通知偏好失敗', e, stack);
      rethrow;
    }
  }

  /// 重置設置
  Future<void> resetSettings() async {
    try {
      _cachedSettings = UserSettings.defaultSettings();
      await updateSettings(_cachedSettings!);
      _logger.info('重置設置成功');
    } catch (e, stack) {
      _logger.error('重置設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_settingsKey)) {
        await _saveSettings(UserSettings.defaultSettings());
      }
      _cachedSettings = await loadSettings();
    } catch (e, stack) {
      _logger.error('初始化用戶設置失敗', e, stack);
      rethrow;
    }
  }

  Future<UserSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_settingsKey);
      if (jsonStr == null) {
        return UserSettings.defaultSettings();
      }
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserSettings.fromJson(json);
    } catch (e, stack) {
      _logger.error('讀取用戶設置失敗', e, stack);
      return UserSettings.defaultSettings();
    }
  }

  Future<void> _saveSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, jsonStr);
      _cachedSettings = settings;
    } catch (e, stack) {
      _logger.error('保存用戶設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> updateUserZodiac(Zodiac zodiac) async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(zodiac: zodiac);
    await _saveSettings(newSettings);
  }

  Future<void> updateBirthYear(int birthYear) async {
    if (!_isValidBirthYear(birthYear)) {
      throw ArgumentError('無效的出生年份');
    }
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(birthYear: birthYear);
    await _saveSettings(newSettings);
  }

  bool _isValidBirthYear(int year) {
    final now = DateTime.now();
    return year > 1900 && year <= now.year;
  }

  bool isValidZodiac(String zodiac) {
    try {
      return Zodiac.values.any((z) => z.toString() == zodiac);
    } catch (_) {
      return false;
    }
  }

  Zodiac calculateZodiac(int birthYear) {
    return Zodiac.fromYear(birthYear);
  }
} 