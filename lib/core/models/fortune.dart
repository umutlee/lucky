import 'package:flutter/foundation.dart';

enum FortuneType {
  daily,    // 每日運勢
  study,    // 學業運勢
  career,   // 事業運勢
  love,     // 感情運勢
}

class Fortune {
  final FortuneType type;
  final int score;
  final DateTime date;
  final bool isLuckyDay;
  final List<String> luckyDirections;
  final List<String> suitableActivities;
  final String description;
  final double recommendationScore;

  const Fortune({
    required this.type,
    required this.score,
    required this.date,
    this.isLuckyDay = false,
    this.luckyDirections = const [],
    this.suitableActivities = const [],
    this.description = '',
    this.recommendationScore = 0,
  });

  Fortune copyWith({
    FortuneType? type,
    int? score,
    DateTime? date,
    bool? isLuckyDay,
    List<String>? luckyDirections,
    List<String>? suitableActivities,
    String? description,
    double? recommendationScore,
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
    return 'Fortune{type: $type, score: $score, date: $date, isLuckyDay: $isLuckyDay, '
        'luckyDirections: $luckyDirections, suitableActivities: $suitableActivities, '
        'description: $description, recommendationScore: $recommendationScore}';
  }
} 