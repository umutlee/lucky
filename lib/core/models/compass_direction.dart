import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math' as math;

part 'compass_direction.freezed.dart';
part 'compass_direction.g.dart';

/// 指南針方位點
enum CompassPoint {
  north('北'),
  northEast('東北'),
  east('東'),
  southEast('東南'),
  south('南'),
  southWest('西南'),
  west('西'),
  northWest('西北');

  final String displayName;
  const CompassPoint(this.displayName);

  /// 獲取方位角度
  double get angle {
    switch (this) {
      case CompassPoint.north:
        return 0;
      case CompassPoint.northEast:
        return 45;
      case CompassPoint.east:
        return 90;
      case CompassPoint.southEast:
        return 135;
      case CompassPoint.south:
        return 180;
      case CompassPoint.southWest:
        return 225;
      case CompassPoint.west:
        return 270;
      case CompassPoint.northWest:
        return 315;
    }
  }

  /// 獲取方位描述
  String get description {
    switch (this) {
      case CompassPoint.north:
        return '北方代表事業運';
      case CompassPoint.northEast:
        return '東北方代表學習運';
      case CompassPoint.east:
        return '東方代表健康運';
      case CompassPoint.southEast:
        return '東南方代表財運';
      case CompassPoint.south:
        return '南方代表桃花運';
      case CompassPoint.southWest:
        return '西南方代表人際運';
      case CompassPoint.west:
        return '西方代表貴人運';
      case CompassPoint.northWest:
        return '西北方代表創意運';
    }
  }

  /// 從角度獲取方位
  static CompassPoint fromDegrees(double degrees) {
    final normalizedDegrees = ((degrees % 360) + 360) % 360;
    if (normalizedDegrees >= 337.5 || normalizedDegrees < 22.5) return north;
    if (normalizedDegrees < 67.5) return northEast;
    if (normalizedDegrees < 112.5) return east;
    if (normalizedDegrees < 157.5) return southEast;
    if (normalizedDegrees < 202.5) return south;
    if (normalizedDegrees < 247.5) return southWest;
    if (normalizedDegrees < 292.5) return west;
    return northWest;
  }

  /// 從名稱獲取方位
  static CompassPoint fromName(String name) {
    return CompassPoint.values.firstWhere(
      (point) => point.displayName == name,
      orElse: () => CompassPoint.north,
    );
  }

  /// 計算與另一個方位的角度差
  double calculateAngleDifference(CompassPoint other) {
    double diff = (other.angle - angle).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  /// 檢查是否接近另一個方位
  bool isNear(CompassPoint other, {double threshold = 45}) {
    return calculateAngleDifference(other) <= threshold;
  }

  /// 獲取相鄰方位
  List<CompassPoint> getAdjacentPoints() {
    final index = CompassPoint.values.indexOf(this);
    final prev = index > 0 ? CompassPoint.values[index - 1] : CompassPoint.values.last;
    final next = index < CompassPoint.values.length - 1 ? CompassPoint.values[index + 1] : CompassPoint.values.first;
    return [prev, next];
  }

  /// 獲取相反方位
  CompassPoint getOppositePoint() {
    switch (this) {
      case CompassPoint.north:
        return CompassPoint.south;
      case CompassPoint.northEast:
        return CompassPoint.southWest;
      case CompassPoint.east:
        return CompassPoint.west;
      case CompassPoint.southEast:
        return CompassPoint.northWest;
      case CompassPoint.south:
        return CompassPoint.north;
      case CompassPoint.southWest:
        return CompassPoint.northEast;
      case CompassPoint.west:
        return CompassPoint.east;
      case CompassPoint.northWest:
        return CompassPoint.southEast;
    }
  }
}

@freezed
class CompassState with _$CompassState {
  const factory CompassState({
    required double heading,
    required CompassPoint direction,
    String? directionDescription,
    @Default([]) List<String> auspiciousDirections,
    String? error,
    @Default(false) bool isLoading,
  }) = _CompassState;

  factory CompassState.initial() => const CompassState(
        heading: 0.0,
        direction: CompassPoint.north,
        isLoading: false,
      );

  factory CompassState.fromJson(Map<String, dynamic> json) => _$CompassStateFromJson(json);
} 