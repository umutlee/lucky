import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../models/zodiac.dart';
import 'storage_service.dart';

final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  final storage = ref.read(storageServiceProvider);
  return UserSettingsService(storage);
});

/// 用戶設置服務
class UserSettingsService {
  final StorageService _storage;
  static const String _settingsKey = 'user_settings';

  UserSettingsService(this._storage);

  /// 獲取用戶設置
  Future<UserSettings> getSettings() async {
    try {
      final jsonString = _storage.getString(_settingsKey);
      if (jsonString == null) {
        return UserSettings.defaultSettings();
      }
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserSettings.fromJson(jsonMap);
    } catch (e) {
      return UserSettings.defaultSettings();
    }
  }

  /// 保存用戶設置
  Future<void> saveSettings(UserSettings settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      await _storage.setString(_settingsKey, jsonString);
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  /// 更新主題設置
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(themeMode: themeMode);
      await saveSettings(newSettings);
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  /// 更新語言設置
  Future<void> updateLocale(String locale) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(locale: locale);
      await saveSettings(newSettings);
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  /// 更新通知設置
  Future<void> updateNotificationSettings(bool enabled) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(notificationsEnabled: enabled);
      await saveSettings(newSettings);
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  /// 更新自動備份設置
  Future<void> updateAutoBackupSettings(bool enabled) async {
    try {
      final settings = await getSettings();
      final newSettings = settings.copyWith(autoBackupEnabled: enabled);
      await saveSettings(newSettings);
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  /// 重置所有設置
  Future<void> resetSettings() async {
    try {
      await saveSettings(UserSettings.defaultSettings());
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  Future<void> init() async {
    // 初始化服務
    if (!_storage.containsKey(_settingsKey)) {
      await _saveSettings(UserSettings.defaultSettings());
    }
  }

  Future<UserSettings> loadSettings() async {
    try {
      final jsonStr = _storage.getString(_settingsKey);
      if (jsonStr == null) {
        return UserSettings.defaultSettings();
      }
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserSettings.fromJson(json);
    } catch (e) {
      print('讀取用戶設置失敗: $e');
      return UserSettings.defaultSettings();
    }
  }

  Future<void> updateUserZodiac(Zodiac zodiac) async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(zodiac: zodiac);
    await _saveSettings(newSettings);
  }

  Future<void> updateBirthYear(int birthYear) async {
    if (!isValidBirthYear(birthYear)) {
      throw ArgumentError('無效的出生年份');
    }
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(birthYear: birthYear);
    await _saveSettings(newSettings);
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(hasEnabledNotifications: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> updateLocationPermission(bool granted) async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(hasLocationPermission: granted);
    await _saveSettings(newSettings);
  }

  Future<void> completeOnboarding() async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(
      hasCompletedOnboarding: true,
      isFirstLaunch: false,
    );
    await _saveSettings(newSettings);
  }

  Future<void> acceptTerms() async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(hasAcceptedTerms: true);
    await _saveSettings(newSettings);
  }

  Future<void> acceptPrivacy() async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(hasAcceptedPrivacy: true);
    await _saveSettings(newSettings);
  }

  Future<void> _saveSettings(UserSettings settings) async {
    try {
      final jsonStr = jsonEncode(settings.toJson());
      await _storage.setString(_settingsKey, jsonStr);
    } catch (e) {
      print('保存用戶設置失敗: $e');
      rethrow;
    }
  }

  bool isValidBirthYear(int year) {
    final currentYear = DateTime.now().year;
    return year >= 1900 && year <= currentYear;
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