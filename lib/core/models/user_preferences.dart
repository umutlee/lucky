import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
@HiveType(typeId: 1)
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @HiveField(0)
    @Default(true)
    bool enableDailyNotification,
    @HiveField(1)
    @Default('08:00')
    String dailyNotificationTime,
    @HiveField(2)
    @Default(true)
    bool enableVibration,
    @HiveField(3)
    @Default(true)
    bool enableSound,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
} 