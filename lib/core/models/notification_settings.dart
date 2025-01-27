import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:json_annotation/json_annotation.dart';

part 'notification_settings.g.dart';

@JsonSerializable()
class NotificationSettings {
  final bool enableDailyFortune;
  @JsonKey(toJson: _timeOfDayToJson, fromJson: _timeOfDayFromJson)
  final TimeOfDay dailyNotificationTime;
  final bool enableSolarTerm;
  @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
  final Duration solarTermPreNotifyDuration;
  final bool enableLuckyDay;

  const NotificationSettings({
    this.enableDailyFortune = true,
    this.dailyNotificationTime = const TimeOfDay(hour: 8, minute: 0),
    this.enableSolarTerm = true,
    this.solarTermPreNotifyDuration = const Duration(days: 1),
    this.enableLuckyDay = true,
  });

  NotificationSettings copyWith({
    bool? enableDailyFortune,
    TimeOfDay? dailyNotificationTime,
    bool? enableSolarTerm,
    Duration? solarTermPreNotifyDuration,
    bool? enableLuckyDay,
  }) {
    return NotificationSettings(
      enableDailyFortune: enableDailyFortune ?? this.enableDailyFortune,
      dailyNotificationTime: dailyNotificationTime ?? this.dailyNotificationTime,
      enableSolarTerm: enableSolarTerm ?? this.enableSolarTerm,
      solarTermPreNotifyDuration: solarTermPreNotifyDuration ?? this.solarTermPreNotifyDuration,
      enableLuckyDay: enableLuckyDay ?? this.enableLuckyDay,
    );
  }

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

  static Map<String, int> _timeOfDayToJson(TimeOfDay time) => {
    'hour': time.hour,
    'minute': time.minute,
  };

  static TimeOfDay _timeOfDayFromJson(Map<String, dynamic> json) => TimeOfDay(
    hour: json['hour'] as int,
    minute: json['minute'] as int,
  );

  static int _durationToJson(Duration duration) => duration.inDays;

  static Duration _durationFromJson(int days) => Duration(days: days);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          enableDailyFortune == other.enableDailyFortune &&
          dailyNotificationTime == other.dailyNotificationTime &&
          enableSolarTerm == other.enableSolarTerm &&
          solarTermPreNotifyDuration == other.solarTermPreNotifyDuration &&
          enableLuckyDay == other.enableLuckyDay;

  @override
  int get hashCode =>
      enableDailyFortune.hashCode ^
      dailyNotificationTime.hashCode ^
      enableSolarTerm.hashCode ^
      solarTermPreNotifyDuration.hashCode ^
      enableLuckyDay.hashCode;

  @override
  String toString() {
    return 'NotificationSettings('
        'enableDailyFortune: $enableDailyFortune, '
        'dailyNotificationTime: $dailyNotificationTime, '
        'enableSolarTerm: $enableSolarTerm, '
        'solarTermPreNotifyDuration: ${solarTermPreNotifyDuration.inDays}天, '
        'enableLuckyDay: $enableLuckyDay)';
  }
}