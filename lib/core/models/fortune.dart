import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune.freezed.dart';
part 'fortune.g.dart';

@freezed
class Fortune with _$Fortune {
  const factory Fortune({
    required String id,
    required String type,
    required String title,
    required String description,
    required double score,
    required DateTime date,
    required String zodiac,
    @Default(false) bool isLuckyDay,
    @Default({}) Map<String, int> zodiacAffinity,
    @Default([]) List<String> recommendations,
  }) = _Fortune;

  factory Fortune.fromJson(Map<String, dynamic> json) => _$FortuneFromJson(json);
}

enum FortuneType {
  daily,    // 每日運勢
  study,    // 學業運勢
  career,   // 事業運勢
  love,     // 感情運勢
} 