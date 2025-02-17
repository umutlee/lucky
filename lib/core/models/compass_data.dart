import 'package:freezed_annotation/freezed_annotation.dart';
import 'compass_direction.dart';

part 'compass_data.freezed.dart';
part 'compass_data.g.dart';

@freezed
class CompassData with _$CompassData {
  const factory CompassData({
    required double angle,
    required CompassPoint direction,
    required double rawX,
    required double rawY,
    required double rawZ,
    required bool isCalibrated,
    required double accuracy,
  }) = _CompassData;

  factory CompassData.fromJson(Map<String, dynamic> json) => _$CompassDataFromJson(json);
} 