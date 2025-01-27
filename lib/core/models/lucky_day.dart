import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lucky_day.g.dart';

@JsonSerializable()
class LuckyDay {
  final DateTime date;
  final String description;
  final List<String>? suitableActivities;
  final List<String>? luckyDirections;
  final int? score;

  const LuckyDay({
    required this.date,
    required this.description,
    this.suitableActivities,
    this.luckyDirections,
    this.score,
  });

  Map<String, dynamic> toJson() => _$LuckyDayToJson(this);

  factory LuckyDay.fromJson(Map<String, dynamic> json) => _$LuckyDayFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LuckyDay &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          description == other.description &&
          listEquals(suitableActivities, other.suitableActivities) &&
          listEquals(luckyDirections, other.luckyDirections) &&
          score == other.score;

  @override
  int get hashCode =>
      date.hashCode ^
      description.hashCode ^
      suitableActivities.hashCode ^
      luckyDirections.hashCode ^
      score.hashCode;

  @override
  String toString() {
    return 'LuckyDay('
        'date: $date, '
        'description: $description, '
        'suitableActivities: $suitableActivities, '
        'luckyDirections: $luckyDirections, '
        'score: $score)';
  }
} 