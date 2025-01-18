import 'package:flutter/foundation.dart';

@immutable
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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'description': description,
      'suitableActivities': suitableActivities,
      'luckyDirections': luckyDirections,
      'score': score,
    };
  }

  factory LuckyDay.fromJson(Map<String, dynamic> json) {
    return LuckyDay(
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      suitableActivities: (json['suitableActivities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      luckyDirections: (json['luckyDirections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      score: json['score'] as int?,
    );
  }

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