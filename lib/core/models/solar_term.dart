import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'solar_term.g.dart';

@JsonSerializable()
class SolarTerm {
  final String name;
  final DateTime date;
  final String? description;

  const SolarTerm({
    required this.name,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toJson() => _$SolarTermToJson(this);

  factory SolarTerm.fromJson(Map<String, dynamic> json) => _$SolarTermFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolarTerm &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          date == other.date &&
          description == other.description;

  @override
  int get hashCode => name.hashCode ^ date.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'SolarTerm(name: $name, date: $date, description: $description)';
  }
} 