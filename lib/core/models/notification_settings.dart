import 'package:flutter/foundation.dart';

@immutable
class NotificationSettings {
  final bool enableDailyFortune;
  final bool enableSolarTerm;
  final bool enableLuckyDay;
  final TimeOfDay dailyNotificationTime;
  final Duration solarTermPreNotifyDuration;

  const NotificationSettings({
    this.enableDailyFortune = true,
    this.enableSolarTerm = true,
    this.enableLuckyDay = true,
    this.dailyNotificationTime = const TimeOfDay(hour: 8, minute: 0),
    this.solarTermPreNotifyDuration = const Duration(days: 1),
  });

  NotificationSettings copyWith({
    bool? enableDailyFortune,
    bool? enableSolarTerm,
    bool? enableLuckyDay,
    TimeOfDay? dailyNotificationTime,
    Duration? solarTermPreNotifyDuration,
  }) {
    return NotificationSettings(
      enableDailyFortune: enableDailyFortune ?? this.enableDailyFortune,
      enableSolarTerm: enableSolarTerm ?? this.enableSolarTerm,
      enableLuckyDay: enableLuckyDay ?? this.enableLuckyDay,
      dailyNotificationTime: dailyNotificationTime ?? this.dailyNotificationTime,
      solarTermPreNotifyDuration: solarTermPreNotifyDuration ?? this.solarTermPreNotifyDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableDailyFortune': enableDailyFortune,
      'enableSolarTerm': enableSolarTerm,
      'enableLuckyDay': enableLuckyDay,
      'dailyNotificationHour': dailyNotificationTime.hour,
      'dailyNotificationMinute': dailyNotificationTime.minute,
      'solarTermPreNotifyDays': solarTermPreNotifyDuration.inDays,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enableDailyFortune: json['enableDailyFortune'] as bool? ?? true,
      enableSolarTerm: json['enableSolarTerm'] as bool? ?? true,
      enableLuckyDay: json['enableLuckyDay'] as bool? ?? true,
      dailyNotificationTime: TimeOfDay(
        hour: json['dailyNotificationHour'] as int? ?? 8,
        minute: json['dailyNotificationMinute'] as int? ?? 0,
      ),
      solarTermPreNotifyDuration: Duration(
        days: json['solarTermPreNotifyDays'] as int? ?? 1,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          enableDailyFortune == other.enableDailyFortune &&
          enableSolarTerm == other.enableSolarTerm &&
          enableLuckyDay == other.enableLuckyDay &&
          dailyNotificationTime == other.dailyNotificationTime &&
          solarTermPreNotifyDuration == other.solarTermPreNotifyDuration;

  @override
  int get hashCode =>
      enableDailyFortune.hashCode ^
      enableSolarTerm.hashCode ^
      enableLuckyDay.hashCode ^
      dailyNotificationTime.hashCode ^
      solarTermPreNotifyDuration.hashCode;

  @override
  String toString() {
    return 'NotificationSettings('
        'enableDailyFortune: $enableDailyFortune, '
        'enableSolarTerm: $enableSolarTerm, '
        'enableLuckyDay: $enableLuckyDay, '
        'dailyNotificationTime: $dailyNotificationTime, '
        'solarTermPreNotifyDuration: $solarTermPreNotifyDuration)';
  }
} 