import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'compass_direction.freezed.dart';
part 'compass_direction.g.dart';

enum CompassDirection {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest;

  @override
  String toString() {
    switch (this) {
      case CompassDirection.north:
        return '北';
      case CompassDirection.northEast:
        return '東北';
      case CompassDirection.east:
        return '東';
      case CompassDirection.southEast:
        return '東南';
      case CompassDirection.south:
        return '南';
      case CompassDirection.southWest:
        return '西南';
      case CompassDirection.west:
        return '西';
      case CompassDirection.northWest:
        return '西北';
    }
  }
}

@immutable
class CompassState {
  final double heading;
  final CompassDirection currentDirection;
  final String? directionDescription;
  final List<String>? auspiciousDirections;
  final bool isLoading;
  final String? error;

  const CompassState({
    this.heading = 0.0,
    this.currentDirection = CompassDirection.north,
    this.directionDescription,
    this.auspiciousDirections,
    this.isLoading = false,
    this.error,
  });

  CompassState copyWith({
    double? heading,
    CompassDirection? currentDirection,
    String? directionDescription,
    List<String>? auspiciousDirections,
    bool? isLoading,
    String? error,
  }) {
    return CompassState(
      heading: heading ?? this.heading,
      currentDirection: currentDirection ?? this.currentDirection,
      directionDescription: directionDescription ?? this.directionDescription,
      auspiciousDirections: auspiciousDirections ?? this.auspiciousDirections,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompassState &&
        other.heading == heading &&
        other.currentDirection == currentDirection &&
        other.directionDescription == directionDescription &&
        listEquals(other.auspiciousDirections, auspiciousDirections) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      heading,
      currentDirection,
      directionDescription,
      Object.hashAll(auspiciousDirections ?? []),
      isLoading,
      error,
    );
  }
}

@freezed
class CompassDirection with _$CompassDirection {
  const factory CompassDirection({
    required String name,
    required double angle,
  }) = _CompassDirection;

  const CompassDirection._();

  factory CompassDirection.fromJson(Map<String, dynamic> json) =>
      _$CompassDirectionFromJson(json);

  static const north = CompassDirection(name: '北', angle: 0.0);
  static const northeast = CompassDirection(name: '東北', angle: 45.0);
  static const east = CompassDirection(name: '東', angle: 90.0);
  static const southeast = CompassDirection(name: '東南', angle: 135.0);
  static const south = CompassDirection(name: '南', angle: 180.0);
  static const southwest = CompassDirection(name: '西南', angle: 225.0);
  static const west = CompassDirection(name: '西', angle: 270.0);
  static const northwest = CompassDirection(name: '西北', angle: 315.0);

  static const allDirections = [
    north,
    northeast,
    east,
    southeast,
    south,
    southwest,
    west,
    northwest,
  ];

  bool isNear(double targetAngle, {double tolerance = 10.0}) {
    return calculateAngleDifference(angle, targetAngle) <= tolerance;
  }

  static double calculateAngleDifference(double angle1, double angle2) {
    final diff = (angle1 - angle2).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  static CompassDirection getDirection(double heading) {
    final normalizedHeading = heading % 360;
    return allDirections.reduce((a, b) {
      final diffA = calculateAngleDifference(a.angle, normalizedHeading);
      final diffB = calculateAngleDifference(b.angle, normalizedHeading);
      return diffA < diffB ? a : b;
    });
  }

  static CompassDirection fromDegrees(double degrees) {
    return getDirection(degrees);
  }

  String get direction => name;

  static CompassDirection fromName(String name) {
    return allDirections.firstWhere(
      (direction) => direction.name == name,
      orElse: () => CompassDirection.north,
    );
  }
} 