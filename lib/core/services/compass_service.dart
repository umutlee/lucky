import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../models/compass_direction.dart';
import '../utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final compassProvider = StreamProvider<CompassDirection>((ref) {
  return FlutterCompass.events?.map((event) {
    final heading = event.heading ?? 0.0;
    return CompassDirection.getDirection(heading);
  }) ?? Stream.value(CompassDirection.north);
});

class CompassService {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  final _logger = Logger('CompassService');
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamController<CompassDirection>? _directionController;

  static const Map<int, String> _directions = {
    0: '北',
    45: '東北',
    90: '東',
    135: '東南',
    180: '南',
    225: '西南',
    270: '西',
    315: '西北',
  };

  // 獲取方位流
  Stream<CompassDirection> get directionStream {
    _directionController ??= StreamController<CompassDirection>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _directionController!.stream;
  }

  // 開始監聽方位變化
  void _startListening() async {
    try {
      // 檢查權限
      final permission = await _checkLocationPermission();
      if (!permission) {
        _logger.warning('未獲得位置權限');
        return;
      }

      // 檢查羅盤是否可用
      if (!await FlutterCompass.events!.isEmpty) {
        _compassSubscription = FlutterCompass.events!.listen(
          (CompassEvent event) {
            if (event.heading != null) {
              final direction = CompassDirection.getDirection(event.heading!);
              _directionController?.add(direction);
            }
          },
          onError: (error) {
            _logger.error('羅盤事件錯誤', error);
          },
        );
      } else {
        _logger.warning('設備不支持羅盤功能');
      }
    } catch (e, stackTrace) {
      _logger.error('啟動羅盤監聽失敗', e, stackTrace);
    }
  }

  // 停止監聽
  void _stopListening() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  // 檢查位置權限
  Future<bool> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        return requested != LocationPermission.denied &&
               requested != LocationPermission.deniedForever;
      }
      return permission != LocationPermission.denied &&
             permission != LocationPermission.deniedForever;
    } catch (e) {
      _logger.error('檢查位置權限失敗', e);
      return false;
    }
  }

  /// 計算兩個角度之間的差值
  double calculateAngleDifference(double angle1, double angle2) {
    final diff = (angle2 - angle1) % 360;
    return diff > 180 ? diff - 360 : diff;
  }

  /// 計算兩個地理位置之間的方位角
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = _degreesToRadians(lat1);
    final phi2 = _degreesToRadians(lat2);
    final lambda1 = _degreesToRadians(lon1);
    final lambda2 = _degreesToRadians(lon2);

    final y = math.sin(lambda2 - lambda1) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(lambda2 - lambda1);
    final theta = math.atan2(y, x);

    return (_radiansToDegrees(theta) + 360) % 360;
  }

  /// 將角度轉換為弧度
  double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;

  /// 將弧度轉換為角度
  double _radiansToDegrees(double radians) => radians * 180.0 / math.pi;

  /// 獲取最近的幸運方位
  CompassDirection getNearestLuckyDirection(double heading, List<String> luckyDirections) {
    if (luckyDirections.isEmpty) return CompassDirection.north;

    final directions = luckyDirections.map((d) => CompassDirection.fromName(d)).toList();
    directions.sort((a, b) {
      final diffA = calculateAngleDifference(heading, a.angle);
      final diffB = calculateAngleDifference(heading, b.angle);
      return diffA.abs().compareTo(diffB.abs());
    });

    return directions.first;
  }

  // 檢查是否為吉利方向
  bool isLuckyDirection(CompassDirection direction, List<String> luckyDirections) {
    return luckyDirections.contains(direction.name);
  }

  // 釋放資源
  void dispose() {
    _stopListening();
    _directionController?.close();
    _directionController = null;
  }

  CompassDirection getDirection(double heading) {
    // 標準化角度到 0-360 範圍
    heading = (heading + 360) % 360;
    
    // 定義所有方向
    final directions = [
      CompassDirection.north,     // 0°
      CompassDirection.northeast, // 45°
      CompassDirection.east,      // 90°
      CompassDirection.southeast, // 135°
      CompassDirection.south,     // 180°
      CompassDirection.southwest, // 225°
      CompassDirection.west,      // 270°
      CompassDirection.northwest, // 315°
    ];
    
    // 找到最接近的方向
    return directions.reduce((a, b) {
      final diffA = calculateAngleDifference(heading, a.angle);
      final diffB = calculateAngleDifference(heading, b.angle);
      return diffA < diffB ? a : b;
    });
  }

  static double normalizeHeading(double heading) {
    return (heading + 360) % 360;
  }
} 