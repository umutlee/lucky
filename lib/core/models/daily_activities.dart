import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_activities.freezed.dart';
part 'daily_activities.g.dart';

@freezed
class DailyActivities with _$DailyActivities {
  const factory DailyActivities({
    required DateTime date,
    @Default([]) List<String> goodActivities,
    @Default([]) List<String> badActivities,
  }) = _DailyActivities;

  factory DailyActivities.fromJson(Map<String, dynamic> json) =>
      _$DailyActivitiesFromJson(json);
} 