import 'package:flutter/foundation.dart';

@immutable
class SolarTerm {
  final String name;
  final DateTime date;
  final String? description;

  const SolarTerm({
    required this.name,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory SolarTerm.fromJson(Map<String, dynamic> json) {
    return SolarTerm(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }

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