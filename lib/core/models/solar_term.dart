import 'package:freezed_annotation/freezed_annotation.dart';

part 'solar_term.freezed.dart';
part 'solar_term.g.dart';

@freezed
class SolarTerm with _$SolarTerm {
  const factory SolarTerm({
    required String name,
    required DateTime date,
  }) = _SolarTerm;

  static final empty = SolarTerm(
    name: '無節氣',
    date: DateTime(1970),
  );

  factory SolarTerm.fromJson(Map<String, dynamic> json) =>
      _$SolarTermFromJson(json);

  const SolarTerm._();

  String get displayName => name;

  @override
  String toString() => '$name ($date)';
} 