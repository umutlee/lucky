import 'package:flutter/foundation.dart';

enum FortuneType {
  daily,    // 每日運勢
  study,    // 學業運勢
  career,   // 事業運勢
  love,     // 感情運勢
}

class Fortune {
  final String id;
  final String description;
  final int score;
  final String type;
  final DateTime date;
  final List<String> recommendations;
  final String zodiac;
  final Map<String, int> zodiacAffinity;

  Fortune({
    required this.id,
    required this.description,
    required this.score,
    required this.type,
    required this.date,
    required this.recommendations,
    required this.zodiac,
    required this.zodiacAffinity,
  });

  Fortune copyWith({
    String? id,
    String? description,
    int? score,
    String? type,
    DateTime? date,
    List<String>? recommendations,
    String? zodiac,
    Map<String, int>? zodiacAffinity,
  }) {
    return Fortune(
      id: id ?? this.id,
      description: description ?? this.description,
      score: score ?? this.score,
      type: type ?? this.type,
      date: date ?? this.date,
      recommendations: recommendations ?? this.recommendations,
      zodiac: zodiac ?? this.zodiac,
      zodiacAffinity: zodiacAffinity ?? this.zodiacAffinity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'score': score,
      'type': type,
      'date': date.toIso8601String(),
      'recommendations': recommendations,
      'zodiac': zodiac,
      'zodiacAffinity': zodiacAffinity,
    };
  }

  factory Fortune.fromJson(Map<String, dynamic> json) {
    return Fortune(
      id: json['id'] as String,
      description: json['description'] as String,
      score: json['score'] as int,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      recommendations: List<String>.from(json['recommendations'] as List),
      zodiac: json['zodiac'] as String,
      zodiacAffinity: Map<String, int>.from(json['zodiacAffinity'] as Map),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fortune &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          description == other.description &&
          score == other.score &&
          type == other.type &&
          date == other.date &&
          recommendations == other.recommendations &&
          zodiac == other.zodiac &&
          zodiacAffinity == other.zodiacAffinity;

  @override
  int get hashCode =>
      id.hashCode ^
      description.hashCode ^
      score.hashCode ^
      type.hashCode ^
      date.hashCode ^
      recommendations.hashCode ^
      zodiac.hashCode ^
      zodiacAffinity.hashCode;
} 