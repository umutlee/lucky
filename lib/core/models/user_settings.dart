import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'zodiac.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(Zodiac.rat) Zodiac zodiac,
    @Default(2000) int birthYear,
    @Default(true) bool hasEnabledNotifications,
    @Default(false) bool hasLocationPermission,
    @Default(false) bool hasCompletedOnboarding,
    @Default(false) bool hasAcceptedTerms,
    @Default(false) bool hasAcceptedPrivacy,
    @Default(true) bool isFirstLaunch,
    @Default([]) List<String> preferredFortuneTypes,
    String? notificationTime,
    String? selectedLanguage,
    String? selectedTheme,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  static UserSettings defaultSettings() {
    return const UserSettings(
      zodiac: Zodiac.rat,
      birthYear: 2000,
      hasEnabledNotifications: true,
      hasLocationPermission: false,
      hasCompletedOnboarding: false,
      hasAcceptedTerms: false,
      hasAcceptedPrivacy: false,
      isFirstLaunch: true,
      preferredFortuneTypes: [],
      notificationTime: '08:00',
      selectedLanguage: 'zh_TW',
      selectedTheme: 'system',
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
      selectedLanguage ?? 'zh_TW';

  String get displayTheme =>
      selectedTheme ?? 'system';

  String get displayNotificationTime =>
      notificationTime ?? '08:00';
}

extension UserSettingsX on UserSettings {
  Map<String, dynamic> toMap() {
    return {
      'zodiac': zodiac.index,
      'birth_year': birthYear,
      'notifications_enabled': hasEnabledNotifications ? 1 : 0,
      'location_permission_granted': hasLocationPermission ? 1 : 0,
      'onboarding_completed': hasCompletedOnboarding ? 1 : 0,
      'terms_accepted': hasAcceptedTerms ? 1 : 0,
      'privacy_accepted': hasAcceptedPrivacy ? 1 : 0,
      'is_first_launch': isFirstLaunch ? 1 : 0,
      'preferred_fortune_types': preferredFortuneTypes,
      'notification_time': notificationTime,
      'selected_language': selectedLanguage,
      'selected_theme': selectedTheme,
    };
  }
} 