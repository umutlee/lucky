import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compass_direction.freezed.dart';
part 'compass_direction.g.dart';

/// 指南針方位點
enum CompassPoint {
  north('北', 0),
  northEast('東北', 45),
  east('東', 90),
  southEast('東南', 135),
  south('南', 180),
  southWest('西南', 225),
  west('西', 270),
  northWest('西北', 315);

  final String displayName;
  final double angle;

  const CompassPoint(this.displayName, this.angle);

  /// 從角度獲取方位
  static CompassPoint fromAngle(double angle) {
    // 標準化角度到 0-360 範圍
    angle = angle % 360;
    if (angle < 0) angle += 360;

    // 定義方位的角度範圍
    if (angle >= 337.5 || angle < 22.5) return CompassPoint.north;
    if (angle >= 22.5 && angle < 67.5) return CompassPoint.northEast;
    if (angle >= 67.5 && angle < 112.5) return CompassPoint.east;
    if (angle >= 112.5 && angle < 157.5) return CompassPoint.southEast;
    if (angle >= 157.5 && angle < 202.5) return CompassPoint.south;
    if (angle >= 202.5 && angle < 247.5) return CompassPoint.southWest;
    if (angle >= 247.5 && angle < 292.5) return CompassPoint.west;
    if (angle >= 292.5 && angle < 337.5) return CompassPoint.northWest;

    return CompassPoint.north; // 預設返回北
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
}

@freezed
class CompassState with _$CompassState {
  const factory CompassState({
    required double heading,
    required CompassPoint direction,
    String? directionDescription,
    @JsonKey(defaultValue: <String>[]) List<String>? auspiciousActivities,
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