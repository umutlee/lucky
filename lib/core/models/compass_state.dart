import 'package:freezed_annotation/freezed_annotation.dart';
import 'compass_direction.dart';

part 'compass_state.freezed.dart';

@freezed
class CompassState with _$CompassState {
  const factory CompassState({
    required double heading,
    required CompassPoint direction,
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
} 