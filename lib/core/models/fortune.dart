import 'package:flutter/foundation.dart';

enum FortuneType {
  overall,
  study,
  career,
  love,
}

class Fortune {
  final FortuneType type;
  final double score;
  final DateTime date;
  final bool isLuckyDay;
  final List<String> luckyDirections;
  final List<String> suitableActivities;
  final String? description;
  final int recommendationScore;

  const Fortune({
    required this.type,
    required this.score,
    required this.date,
    required this.isLuckyDay,
    required this.luckyDirections,
    required this.suitableActivities,
    this.description,
    this.recommendationScore = 0,
  });

  Fortune copyWith({
    FortuneType? type,
    double? score,
    DateTime? date,
    bool? isLuckyDay,
    List<String>? luckyDirections,
    List<String>? suitableActivities,
    String? description,
    int? recommendationScore,
  }) {
    return Fortune(
      type: type ?? this.type,
      score: score ?? this.score,
      date: date ?? this.date,
      isLuckyDay: isLuckyDay ?? this.isLuckyDay,
      luckyDirections: luckyDirections ?? this.luckyDirections,
      suitableActivities: suitableActivities ?? this.suitableActivities,
      description: description ?? this.description,
      recommendationScore: recommendationScore ?? this.recommendationScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fortune &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          score == other.score &&
          date == other.date &&
          isLuckyDay == other.isLuckyDay &&
          listEquals(luckyDirections, other.luckyDirections) &&
          listEquals(suitableActivities, other.suitableActivities) &&
          description == other.description &&
          recommendationScore == other.recommendationScore;

  @override
  int get hashCode =>
      type.hashCode ^
      score.hashCode ^
      date.hashCode ^
      isLuckyDay.hashCode ^
      luckyDirections.hashCode ^
      suitableActivities.hashCode ^
      description.hashCode ^
      recommendationScore.hashCode;

  @override
  String toString() {
    return 'Fortune('
        'type: $type, '
        'score: $score, '
        'date: $date, '
        'isLuckyDay: $isLuckyDay, '
        'luckyDirections: $luckyDirections, '
        'suitableActivities: $suitableActivities, '
        'description: $description, '
        'recommendationScore: $recommendationScore)';
  }

  double get compatibility => score * 0.8 + recommendationScore * 0.2;
} 