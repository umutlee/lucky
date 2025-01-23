import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

@immutable
class NotificationSettings {
  final bool enableDailyFortune;
  final TimeOfDay dailyNotificationTime;
  final bool enableSolarTerm;
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

  Map<String, dynamic> toJson() {
    return {
      'enableDailyFortune': enableDailyFortune,
      'dailyNotificationTime': {
        'hour': dailyNotificationTime.hour,
        'minute': dailyNotificationTime.minute,
      },
      'enableSolarTerm': enableSolarTerm,
      'solarTermPreNotifyDuration': solarTermPreNotifyDuration.inDays,
      'enableLuckyDay': enableLuckyDay,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final timeJson = json['dailyNotificationTime'] as Map<String, dynamic>;
    return NotificationSettings(
      enableDailyFortune: json['enableDailyFortune'] as bool? ?? true,
      dailyNotificationTime: TimeOfDay(
        hour: timeJson['hour'] as int? ?? 8,
        minute: timeJson['minute'] as int? ?? 0,
      ),
      enableSolarTerm: json['enableSolarTerm'] as bool? ?? true,
      solarTermPreNotifyDuration: Duration(days: json['solarTermPreNotifyDuration'] as int? ?? 1),
      enableLuckyDay: json['enableLuckyDay'] as bool? ?? true,
    );
  }

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