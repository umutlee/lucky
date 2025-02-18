import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'zodiac.dart';
import 'fortune_type.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// 主題模式轉換器
class ThemeModeConverter implements JsonConverter<ThemeMode, String> {
  const ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) {
    switch (json) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  String toJson(ThemeMode object) {
    return object.toString().split('.').last;
  }
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(false) bool isFirstLaunch,
    @Default(false) bool hasCompletedOnboarding,
    @Default(false) bool hasAcceptedTerms,
    @Default(false) bool hasAcceptedPrivacy,
    @Default(false) bool hasEnabledNotifications,
    @Default(false) bool hasLocationPermission,
    @Default('zh_TW') String locale,
    @ThemeModeConverter() @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool autoBackupEnabled,
    String? notificationTime,
    Zodiac? zodiac,
    String? chineseZodiac,
    int? birthYear,
    @Default([]) List<FortuneType> preferredFortuneTypes,
    @Default(false) bool notificationsEnabled,
    @Default(false) bool dailyNotification,
  }) = _UserSettings;

  factory UserSettings.defaultSettings() => const UserSettings();

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

  const UserSettings._();

  bool get isSetupComplete =>
      !isFirstLaunch &&
      hasCompletedOnboarding &&
      hasAcceptedTerms &&
      hasAcceptedPrivacy;

  bool get hasNotificationsConfigured =>
      hasEnabledNotifications && notificationTime != null;

  bool get hasLocationConfigured =>
      hasLocationPermission;

  bool get hasFortunePreferences =>
      preferredFortuneTypes.isNotEmpty;

  String get displayLocale =>
      locale;

  String get displayTheme =>
      themeMode.toString().split('.').last;

  Map<String, dynamic> toJson() {
    return {
      'zodiac': zodiac?.name,
      'chinese_zodiac': chineseZodiac,
      'locale': locale,
      'birth_year': birthYear,
      'notifications_enabled': hasEnabledNotifications ? 1 : 0,
      'location_permission_granted': hasLocationPermission ? 1 : 0,
      'onboarding_completed': hasCompletedOnboarding ? 1 : 0,
      'terms_accepted': hasAcceptedTerms ? 1 : 0,
      'privacy_accepted': hasAcceptedPrivacy ? 1 : 0,
      'is_first_launch': isFirstLaunch ? 1 : 0,
      'preferred_fortune_types': preferredFortuneTypes.map((e) => e.name).toList(),
      'theme_mode': themeMode.toString().split('.').last,
      'notification_time': notificationTime,
      'auto_backup_enabled': autoBackupEnabled ? 1 : 0,
      'daily_notification': dailyNotification ? 1 : 0,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
    };
  }
} 