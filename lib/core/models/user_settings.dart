import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'zodiac.dart';

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
    @Default(Zodiac.rat) Zodiac zodiac,
    @Default('鼠') String chineseZodiac,
    @Default(true) bool dailyNotification,
    @Default('09:00') String notificationTime,
    @Default(2000) int birthYear,
    @Default(true) bool hasEnabledNotifications,
    @Default(false) bool hasLocationPermission,
    @Default(false) bool hasCompletedOnboarding,
    @Default(false) bool hasAcceptedTerms,
    @Default(false) bool hasAcceptedPrivacy,
    @Default(true) bool isFirstLaunch,
    @Default([]) List<String> preferredFortuneTypes,
    @Default('zh_TW') String locale,
    @ThemeModeConverter() @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool autoBackupEnabled,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  static UserSettings defaultSettings() {
    return const UserSettings(
      zodiac: Zodiac.rat,
      chineseZodiac: '鼠',
      dailyNotification: true,
      notificationTime: '09:00',
      birthYear: 2000,
      hasEnabledNotifications: true,
      hasLocationPermission: false,
      hasCompletedOnboarding: false,
      hasAcceptedTerms: false,
      hasAcceptedPrivacy: false,
      isFirstLaunch: true,
      preferredFortuneTypes: [],
      locale: 'zh_TW',
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      autoBackupEnabled: true,
    );
  }

  const UserSettings._();

  bool get hasCompletedSetup =>
      !isFirstLaunch &&
      hasCompletedOnboarding &&
      hasAcceptedTerms &&
      hasAcceptedPrivacy;

  bool get canReceiveNotifications =>
      hasEnabledNotifications && notificationTime != null;

  bool get canUseLocation =>
      hasLocationPermission;

  bool get hasPreferredTypes =>
      preferredFortuneTypes.isNotEmpty;

  String get displayLanguage =>
      locale;

  String get displayTheme =>
      themeMode.toString().split('.').last;

  String get displayNotificationTime =>
      notificationTime;
}

extension UserSettingsX on UserSettings {
  Map<String, dynamic> toMap() {
    return {
      'zodiac': zodiac.name,
      'chinese_zodiac': chineseZodiac,
      'daily_notification': dailyNotification ? 1 : 0,
      'notification_time': notificationTime,
      'birth_year': birthYear,
      'notifications_enabled': hasEnabledNotifications ? 1 : 0,
      'location_permission_granted': hasLocationPermission ? 1 : 0,
      'onboarding_completed': hasCompletedOnboarding ? 1 : 0,
      'terms_accepted': hasAcceptedTerms ? 1 : 0,
      'privacy_accepted': hasAcceptedPrivacy ? 1 : 0,
      'is_first_launch': isFirstLaunch ? 1 : 0,
      'preferred_fortune_types': preferredFortuneTypes,
      'locale': locale,
      'theme_mode': themeMode.toString().split('.').last,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'auto_backup_enabled': autoBackupEnabled ? 1 : 0,
    };
  }
} 