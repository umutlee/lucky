import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../models/compass_direction.dart';
import '../services/direction_service.dart';

final compassProvider = StateNotifierProvider<CompassNotifier, CompassState>((ref) {
  return CompassNotifier(DirectionService());
});

class CompassNotifier extends StateNotifier<CompassState> {
  final DirectionService _directionService;
  StreamSubscription<CompassEvent>? _compassSubscription;

  CompassNotifier(this._directionService) : super(const CompassState()) {
    _init();
  }

  void _init() async {
    if (!await FlutterCompass.events.first.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('無法獲取方位感應器數據'),
    )) {
      state = state.copyWith(
        error: '設備不支持方位感應器',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      _compassSubscription = FlutterCompass.events?.listen((event) async {
        if (event.heading == null) return;

        final heading = event.heading!;
        final direction = _getDirection(heading);
        
        state = state.copyWith(
          heading: heading,
          currentDirection: direction,
          isLoading: false,
        );

        // 獲取方位運勢
        try {
          final description = await _directionService.getDirectionDescription(direction);
          final auspicious = await _directionService.getAuspiciousDirections(direction);
          
          state = state.copyWith(
            directionDescription: description,
            auspiciousDirections: auspicious,
          );
        } catch (e) {
          state = state.copyWith(
            error: '無法獲取方位運勢信息',
          );
        }
      });
    } catch (e) {
      state = state.copyWith(
        error: '方位感應器初始化失敗',
        isLoading: false,
      );
    }
  }

  CompassDirection _getDirection(double heading) {
    if (heading < 22.5 || heading >= 337.5) return CompassDirection.north;
    if (heading < 67.5) return CompassDirection.northEast;
    if (heading < 112.5) return CompassDirection.east;
    if (heading < 157.5) return CompassDirection.southEast;
    if (heading < 202.5) return CompassDirection.south;
    if (heading < 247.5) return CompassDirection.southWest;
    if (heading < 292.5) return CompassDirection.west;
    return CompassDirection.northWest;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
} 