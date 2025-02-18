import 'package:freezed_annotation/freezed_annotation.dart';
import 'compass_direction.dart';

part 'compass_state.freezed.dart';
part 'compass_state.g.dart';

@freezed
class CompassState with _$CompassState {
  const factory CompassState({
    required double heading,
    required CompassPoint direction,
    String? directionDescription,
    @Default([]) List<String> auspiciousDirections,
    String? error,
    @Default(false) bool isLoading,
    @Default(false) bool isCalibrating,
    @Default(0.0) double calibrationOffset,
  }) = _CompassState;

  factory CompassState.initial() => const CompassState(
    heading: 0.0,
    direction: CompassPoint.north,
    isLoading: false,
    isCalibrating: false,
    calibrationOffset: 0.0,
  );

  factory CompassState.fromJson(Map<String, dynamic> json) =>
      _$CompassStateFromJson(json);
} 