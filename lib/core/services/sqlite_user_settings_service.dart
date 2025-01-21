import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user_settings.dart';
import '../models/zodiac.dart';
import '../utils/logger.dart';

final sqliteUserSettingsServiceProvider = Provider<SQLiteUserSettingsService>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return SQLiteUserSettingsService(databaseHelper);
});

class SQLiteUserSettingsService {
  static const String _tag = 'SQLiteUserSettingsService';
  final _logger = Logger(_tag);
  final DatabaseHelper _databaseHelper;

  SQLiteUserSettingsService(this._databaseHelper);

  Future<bool> init() async {
    try {
      await _databaseHelper.init();
      return true;
    } catch (e, stackTrace) {
      _logger.error('SQLite 用戶設置服務初始化失敗', e, stackTrace);
      return false;
    }
  }

  Future<UserSettings> getUserSettings() async {
    try {
      final result = await _databaseHelper.query('user_settings');
      if (result.isEmpty) {
        return UserSettings.initial();
      }

      final data = result.first;
      return UserSettings(
        zodiac: data['zodiac'] != null ? Zodiac.values[data['zodiac'] as int] : null,
        birthYear: data['birth_year'] as int?,
        notificationsEnabled: (data['notifications_enabled'] as int) == 1,
        locationPermissionGranted: (data['location_permission_granted'] as int) == 1,
        onboardingCompleted: (data['onboarding_completed'] as int) == 1,
        termsAccepted: (data['terms_accepted'] as int) == 1,
        privacyAccepted: (data['privacy_accepted'] as int) == 1,
      );
    } catch (e, stackTrace) {
      _logger.error('獲取用戶設置失敗', e, stackTrace);
      return UserSettings.initial();
    }
  }

  Future<bool> updateZodiac(Zodiac zodiac) async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(zodiac: zodiac);
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新生肖失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateBirthYear(int year) async {
    try {
      if (year < 1900 || year > DateTime.now().year) {
        throw ArgumentError('無效的出生年份');
      }

      final zodiac = Zodiac.fromYear(year);
      final currentSettings = await getUserSettings();
      final newSettings = UserSettings(
        zodiac: zodiac,
        birthYear: year,
        notificationsEnabled: currentSettings.notificationsEnabled,
        locationPermissionGranted: currentSettings.locationPermissionGranted,
        onboardingCompleted: currentSettings.onboardingCompleted,
        termsAccepted: currentSettings.termsAccepted,
        privacyAccepted: currentSettings.privacyAccepted,
      );
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新出生年份失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateNotificationPreference(bool enabled) async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(notificationsEnabled: enabled);
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新通知偏好失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateLocationPermission(bool granted) async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(locationPermissionGranted: granted);
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新位置權限失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> completeOnboarding() async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(onboardingCompleted: true);
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新引導狀態失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> acceptTerms() async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(termsAccepted: true);
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新條款接受狀態失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> acceptPrivacy() async {
    try {
      final currentSettings = await getUserSettings();
      final newSettings = currentSettings.copyWith(privacyAccepted: true);
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('更新隱私政策接受狀態失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      await _databaseHelper.delete('user_settings');
      return true;
    } catch (e, stackTrace) {
      _logger.error('清除用戶設置失敗', e, stackTrace);
      return false;
    }
  }

  Future<void> _saveSettings(UserSettings settings) async {
    try {
      final data = settings.toMap();
      await _databaseHelper.insert('user_settings', data);
    } catch (e, stackTrace) {
      _logger.error('保存用戶設置失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> migrateFromSharedPreferences(Map<String, dynamic> oldData) async {
    try {
      final zodiac = oldData['zodiac'] != null ? Zodiac.values[oldData['zodiac'] as int] : null;
      final birthYear = oldData['birth_year'] as int?;
      final notificationsEnabled = oldData['notifications_enabled'] as bool? ?? false;
      final locationPermissionGranted = oldData['location_permission_granted'] as bool? ?? false;
      final onboardingCompleted = oldData['onboarding_completed'] as bool? ?? false;
      final termsAccepted = oldData['terms_accepted'] as bool? ?? false;
      final privacyAccepted = oldData['privacy_accepted'] as bool? ?? false;

      final newSettings = UserSettings(
        zodiac: zodiac,
        birthYear: birthYear,
        notificationsEnabled: notificationsEnabled,
        locationPermissionGranted: locationPermissionGranted,
        onboardingCompleted: onboardingCompleted,
        termsAccepted: termsAccepted,
        privacyAccepted: privacyAccepted,
      );
      await _saveSettings(newSettings);
      return true;
    } catch (e, stackTrace) {
      _logger.error('從 SharedPreferences 遷移用戶設置失敗', e, stackTrace);
      return false;
    }
  }
} 