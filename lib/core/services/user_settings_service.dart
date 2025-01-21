import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../models/zodiac.dart';

final userSettingsServiceProvider = Provider<UserSettingsService>(
  (ref) => UserSettingsService(ref.read(sharedPreferencesProvider)),
);

class UserSettingsService {
  final SharedPreferences _prefs;
  static const _settingsKey = 'user_settings';

  UserSettingsService(this._prefs);

  Future<UserSettings> getUserSettings() async {
    try {
      final jsonStr = _prefs.getString(_settingsKey);
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
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(zodiac: zodiac);
    await _saveSettings(newSettings);
  }

  Future<void> updateBirthYear(int birthYear) async {
    if (!_isValidBirthYear(birthYear)) {
      throw ArgumentError('無效的出生年份');
    }
    final currentSettings = await getUserSettings();
    final zodiac = Zodiac.fromYear(birthYear);
    final newSettings = currentSettings.copyWith(
      birthYear: birthYear,
      zodiac: zodiac,
    );
    await _saveSettings(newSettings);
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasEnabledNotifications: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> updateLocationPermission(bool granted) async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasLocationPermission: granted);
    await _saveSettings(newSettings);
  }

  Future<void> completeOnboarding() async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(
      hasCompletedOnboarding: true,
      isFirstLaunch: false,
    );
    await _saveSettings(newSettings);
  }

  Future<void> acceptTerms() async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasAcceptedTerms: true);
    await _saveSettings(newSettings);
  }

  Future<void> acceptPrivacy() async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasAcceptedPrivacy: true);
    await _saveSettings(newSettings);
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final jsonStr = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonStr);
  }

  bool _isValidBirthYear(int year) {
    final currentYear = DateTime.now().year;
    return year > 1900 && year <= currentYear;
  }
} 