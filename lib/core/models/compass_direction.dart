import 'package:flutter/foundation.dart';

@immutable
class CompassDirection {
  final double degrees;      // 角度（0-360）
  final String direction;    // 方位名稱（如：東、南、西、北）
  final bool isLucky;        // 是否為吉利方位
  final String? description; // 方位描述

  const CompassDirection({
    required this.degrees,
    required this.direction,
    this.isLucky = false,
    this.description,
  });

  // 根據角度獲取基本方位
  static String getBaseDirection(double degrees) {
    const directions = ['北', '東北', '東', '東南', '南', '西南', '西', '西北'];
    final index = ((degrees + 22.5) % 360) ~/ 45;
    return directions[index];
  }

  // 從角度創建方位對象
  factory CompassDirection.fromDegrees(double degrees, {
    bool isLucky = false,
    String? description,
  }) {
    final direction = getBaseDirection(degrees);
    return CompassDirection(
      degrees: degrees,
      direction: direction,
      isLucky: isLucky,
      description: description,
    );
  }

  // 檢查兩個方位是否相近（誤差在指定範圍內）
  bool isNear(CompassDirection other, {double tolerance = 22.5}) {
    final diff = (degrees - other.degrees).abs() % 360;
    return diff <= tolerance || diff >= 360 - tolerance;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompassDirection &&
          runtimeType == other.runtimeType &&
          degrees == other.degrees &&
          direction == other.direction &&
          isLucky == other.isLucky &&
          description == other.description;

  @override
  int get hashCode =>
      degrees.hashCode ^
      direction.hashCode ^
      isLucky.hashCode ^
      description.hashCode;

  @override
  String toString() {
    return 'CompassDirection('
        'degrees: $degrees, '
        'direction: $direction, '
        'isLucky: $isLucky, '
        'description: $description)';
  }

  Map<String, dynamic> toJson() {
    return {
      'degrees': degrees,
      'direction': direction,
      'isLucky': isLucky,
      'description': description,
    };
  }

  factory CompassDirection.fromJson(Map<String, dynamic> json) {
    return CompassDirection(
      degrees: json['degrees'] as double,
      direction: json['direction'] as String,
      isLucky: json['isLucky'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }
} 