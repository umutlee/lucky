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
        _logger.error('無法獲取位置權限');
        _directionController?.addError('無法獲取位置權限');
        return;
      }

      // 檢查指南針可用性
      if (!(await FlutterCompass.events?.isEmpty ?? true)) {
        _logger.error('設備不支持指南針功能');
        _directionController?.addError('設備不支持指南針功能');
        return;
      }

      // 訂閱指南針事件
      _compassSubscription = FlutterCompass.events?.listen(
        (event) {
          if (event.heading != null) {
            final direction = getDirection(event.heading!);
            _directionController?.add(direction);
          }
        },
        onError: (error) {
          _logger.error('指南針事件錯誤: $error');
          _directionController?.addError(error);
        },
      );
    } catch (e) {
      _logger.error('啟動指南針監聽失敗: $e');
      _directionController?.addError(e);
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
      _logger.error('檢查位置權限失敗: $e');
      return false;
    }
  }

  // 計算兩點之間的方位角
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const rad = math.pi / 180;
    final dLon = (endLongitude - startLongitude) * rad;

    final lat1 = startLatitude * rad;
    final lat2 = endLatitude * rad;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  // 檢查方位是否吉利
  bool isLuckyDirection(CompassDirection direction, List<String> luckyDirections) {
    return luckyDirections.contains(direction.name);
  }

  // 獲取最近的吉利方位
  CompassDirection? getNearestLuckyDirection(
    CompassDirection current,
    List<String> luckyDirections,
  ) {
    if (luckyDirections.isEmpty) return null;

    double minDiff = 360;
    CompassDirection? nearest;

    for (final direction in luckyDirections) {
      final degrees = _directionToDegrees(direction);
      final diff = (current.angle - degrees).abs() % 360;
      if (diff < minDiff) {
        minDiff = diff;
        nearest = CompassDirection.fromDegrees(
          degrees,
          isLucky: true,
          description: '最近的吉利方位',
        );
      }
    }

    return nearest;
  }

  // 將方位名稱轉換為角度
  double _directionToDegrees(String direction) {
    const directions = {
      '北': 0.0,
      '東北': 45.0,
      '東': 90.0,
      '東南': 135.0,
      '南': 180.0,
      '西南': 225.0,
      '西': 270.0,
      '西北': 315.0,
    };
    return directions[direction] ?? 0.0;
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

  double calculateAngleDifference(double angle1, double angle2) {
    final diff = (angle1 - angle2).abs() % 360;
    return math.min(diff, 360 - diff);
  }

  static double normalizeHeading(double heading) {
    return (heading + 360) % 360;
  }

  static double calculateAngleDifference(double angle1, double angle2) {
    final diff = (angle1 - angle2).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }
} 