import 'package:freezed_annotation/freezed_annotation.dart';

part 'almanac.freezed.dart';
part 'almanac.g.dart';

@freezed
class Almanac with _$Almanac {
  const factory Almanac({
    required DateTime date,
    required String solarTerm,
    required String lunarDate,
    required List<String> goodActivities,
    required List<String> badActivities,
    required List<String> luckyDirections,
    required List<String> unluckyDirections,
    required Map<String, int> zodiacLuck,
    required String dailyAdvice,
    @Default(false) bool isCached,
  }) = _Almanac;

  factory Almanac.fromJson(Map<String, dynamic> json) => _$AlmanacFromJson(json);

  static Almanac empty() {
    return Almanac(
      date: DateTime.now(),
      solarTerm: '',
      lunarDate: '',
      goodActivities: const [],
      badActivities: const [],
      luckyDirections: const [],
      unluckyDirections: const [],
      zodiacLuck: const {},
      dailyAdvice: '',
    );
  }
} 