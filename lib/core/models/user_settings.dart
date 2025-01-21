import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:all_lucky/core/models/zodiac.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(true) bool isFirstLaunch,
    @Default(false) bool hasAcceptedTerms,
    @Default(false) bool hasAcceptedPrivacy,
    @Default(false) bool hasCompletedOnboarding,
    @Default(false) bool hasEnabledNotifications,
    @Default(false) bool hasLocationPermission,
    @Default([]) List<String> preferredFortuneTypes,
    Zodiac? zodiac,
    int? birthYear,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  factory UserSettings.defaultSettings() => const UserSettings();
} 