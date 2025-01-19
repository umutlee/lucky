import 'package:flutter/foundation.dart';

@immutable
class NotificationSettings {
  final bool enableDailyFortune;
  final TimeOfDay dailyNotificationTime;

  const NotificationSettings({
    this.enableDailyFortune = true,
    this.dailyNotificationTime = const TimeOfDay(hour: 8, minute: 0),
  });

  NotificationSettings copyWith({
    bool? enableDailyFortune,
    TimeOfDay? dailyNotificationTime,
  }) {
    return NotificationSettings(
      enableDailyFortune: enableDailyFortune ?? this.enableDailyFortune,
      dailyNotificationTime: dailyNotificationTime ?? this.dailyNotificationTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableDailyFortune': enableDailyFortune,
      'dailyNotificationTime': {
        'hour': dailyNotificationTime.hour,
        'minute': dailyNotificationTime.minute,
      },
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          enableDailyFortune == other.enableDailyFortune &&
          dailyNotificationTime == other.dailyNotificationTime;

  @override
  int get hashCode =>
      enableDailyFortune.hashCode ^
      dailyNotificationTime.hashCode;

  @override
  String toString() {
    return 'NotificationSettings('
        'enableDailyFortune: $enableDailyFortune, '
        'dailyNotificationTime: $dailyNotificationTime)';
  }
} 