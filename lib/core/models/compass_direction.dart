import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'compass_direction.freezed.dart';
part 'compass_direction.g.dart';

enum Direction {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest;

  String get displayName {
    switch (this) {
      case Direction.north:
        return '北';
      case Direction.northEast:
        return '東北';
      case Direction.east:
        return '東';
      case Direction.southEast:
        return '東南';
      case Direction.south:
        return '南';
      case Direction.southWest:
        return '西南';
      case Direction.west:
        return '西';
      case Direction.northWest:
        return '西北';
    }
  }

  double get angle {
    switch (this) {
      case Direction.north:
        return 0.0;
      case Direction.northEast:
        return 45.0;
      case Direction.east:
        return 90.0;
      case Direction.southEast:
        return 135.0;
      case Direction.south:
        return 180.0;
      case Direction.southWest:
        return 225.0;
      case Direction.west:
        return 270.0;
      case Direction.northWest:
        return 315.0;
    }
  }

  static Direction fromAngle(double angle) {
    final normalizedAngle = (angle + 360) % 360;
    if (normalizedAngle < 22.5) return Direction.north;
    if (normalizedAngle < 67.5) return Direction.northEast;
    if (normalizedAngle < 112.5) return Direction.east;
    if (normalizedAngle < 157.5) return Direction.southEast;
    if (normalizedAngle < 202.5) return Direction.south;
    if (normalizedAngle < 247.5) return Direction.southWest;
    if (normalizedAngle < 292.5) return Direction.west;
    if (normalizedAngle < 337.5) return Direction.northWest;
    return Direction.north;
  }
}

@freezed
class CompassState with _$CompassState {
  const factory CompassState({
    required double heading,
    Direction? currentDirection,
    @Default(false) bool isCalibrating,
    @Default(false) bool hasError,
    String? errorMessage,
    List<String>? auspiciousDirections,
  }) = _CompassState;

  factory CompassState.initial() => const CompassState(
        heading: 0.0,
        currentDirection: Direction.north,
      );

  factory CompassState.fromJson(Map<String, dynamic> json) =>
      _$CompassStateFromJson(json);
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