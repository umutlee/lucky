import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:all_lucky/core/models/zodiac.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(null) Zodiac? zodiac,
    @Default(null) int? birthYear,
    @Default(false) bool notificationsEnabled,
    @Default(false) bool locationPermissionGranted,
    @Default(false) bool onboardingCompleted,
    @Default(false) bool termsAccepted,
    @Default(false) bool privacyAccepted,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  factory UserSettings.defaultSettings() => const UserSettings();

  factory UserSettings.initial() {
    return const UserSettings();
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      zodiac: map['zodiac'] != null ? Zodiac.values[map['zodiac'] as int] : null,
      birthYear: map['birth_year'] as int?,
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      locationPermissionGranted: (map['location_permission_granted'] as int) == 1,
      onboardingCompleted: (map['onboarding_completed'] as int) == 1,
      termsAccepted: (map['terms_accepted'] as int) == 1,
      privacyAccepted: (map['privacy_accepted'] as int) == 1,
    );
  }
}

extension UserSettingsX on UserSettings {
  Map<String, dynamic> toMap() {
    return {
      'zodiac': zodiac?.index,
      'birth_year': birthYear,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'location_permission_granted': locationPermissionGranted ? 1 : 0,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
      'terms_accepted': termsAccepted ? 1 : 0,
      'privacy_accepted': privacyAccepted ? 1 : 0,
    };
  }
} 