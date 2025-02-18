import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../models/compass_direction.dart';
import '../models/compass_data.dart';
import '../utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'logger_service.dart';

/// 指南針數據提供者
final compassDataProvider = StreamProvider<CompassData>((ref) {
  final compassService = ref.watch(compassServiceProvider);
  return compassService.calibratedCompassStream;
});

/// 指南針服務提供者
final compassServiceProvider = Provider<CompassService>((ref) {
  return CompassService();
});

/// 指南針服務
class CompassService {
  final Logger _logger = Logger('CompassService');
  StreamController<CompassPoint>? _directionController;
  StreamController<CompassData>? _dataController;

  /// 獲取當前方向
  Future<CompassPoint> getDirection(double heading) async {
    try {
      return CompassPoint.fromDegrees(heading);
    } catch (e, stack) {
      _logger.error('獲取方向失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取方向描述
  Future<String> getDirectionDescription(CompassPoint direction) async {
    try {
      return direction.description;
    } catch (e, stack) {
      _logger.error('獲取方向描述失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取吉利方向
  Future<List<String>> getAuspiciousDirections(CompassPoint direction) async {
    try {
      // 模擬根據當前方向計算吉利方向
      switch (direction) {
        case CompassPoint.north:
          return ['東北', '西北'];
        case CompassPoint.northEast:
          return ['東', '北'];
        case CompassPoint.east:
          return ['東北', '東南'];
        case CompassPoint.southEast:
          return ['東', '南'];
        case CompassPoint.south:
          return ['東南', '西南'];
        case CompassPoint.southWest:
          return ['南', '西'];
        case CompassPoint.west:
          return ['西南', '西北'];
        case CompassPoint.northWest:
          return ['西', '北'];
      }
    } catch (e, stack) {
      _logger.error('獲取吉利方向失敗', e, stack);
      rethrow;
    }
  }

  /// 開始監聽方向變化
  Stream<CompassPoint> getDirectionStream() {
    _directionController ??= StreamController<CompassPoint>.broadcast(
      onListen: () {
        _logger.info('開始監聽方向變化');
      },
      onCancel: () {
        _logger.info('停止監聽方向變化');
        _directionController?.close();
        _directionController = null;
      },
    );

    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        final direction = CompassPoint.fromDegrees(event.heading!);
        _directionController?.add(direction);
      }
    });

    return _directionController!.stream;
  }

  /// 獲取校準後的羅盤數據流
  Stream<CompassData> get calibratedCompassStream {
    _dataController ??= StreamController<CompassData>.broadcast(
      onListen: () {
        _logger.info('開始監聽羅盤數據');
        _startSensorListening();
      },
      onCancel: () {
        _logger.info('停止監聽羅盤數據');
        _stopSensorListening();
      },
    );

    return _dataController!.stream;
  }

  void _startSensorListening() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        final data = CompassData(
          angle: event.heading!,
          direction: _getDirectionFromAngle(event.heading!),
          rawX: 0,
          rawY: 0,
          rawZ: 0,
          isCalibrated: true,
          accuracy: 1.0,
        );
        _dataController?.add(data);
      }
    });
  }

  void _stopSensorListening() {
    _dataController?.close();
    _dataController = null;
  }

  String _getDirectionFromAngle(double angle) {
    const directions = ['北', '東北', '東', '東南', '南', '西南', '西', '西北'];
    final index = ((angle + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  /// 停止監聽方向變化
  void stopDirectionTracking() {
    _directionController?.close();
    _directionController = null;
  }

  /// 獲取最佳方向
  Future<CompassPoint> getBestDirection(List<String> luckyDirections) async {
    if (luckyDirections.isEmpty) return CompassPoint.north;

    final directions = luckyDirections.map((d) => CompassPoint.fromName(d)).toList();
    
    // 獲取當前方向
    final currentHeading = await FlutterCompass.events!.first;
    if (currentHeading.heading == null) return CompassPoint.north;
    
    final currentDirection = CompassPoint.fromDegrees(currentHeading.heading!);
    
    // 找到最接近的吉利方向
    CompassPoint bestDirection = directions.first;
    double minDifference = currentDirection.calculateAngleDifference(bestDirection);
    
    for (final direction in directions.skip(1)) {
      final difference = currentDirection.calculateAngleDifference(direction);
      if (difference < minDifference) {
        minDifference = difference;
        bestDirection = direction;
      }
    }
    
    return bestDirection;
  }

  /// 檢查是否為吉利方向
  bool isLuckyDirection(CompassPoint direction, List<String> luckyDirections) {
    return luckyDirections.any((d) => CompassPoint.fromName(d) == direction);
  }

  /// 獲取所有方位
  List<CompassPoint> getAllDirections() {
    return [
      CompassPoint.north,     // 0°
      CompassPoint.northEast, // 45°
      CompassPoint.east,      // 90°
      CompassPoint.southEast, // 135°
      CompassPoint.south,     // 180°
      CompassPoint.southWest, // 225°
      CompassPoint.west,      // 270°
      CompassPoint.northWest, // 315°
    ];
  }
}

class CompassData {
  final double angle;
  final String direction;
  final double rawX;
  final double rawY;
  final double rawZ;
  final bool isCalibrated;
  final double accuracy;

  CompassData({
    required this.angle,
    required this.direction,
    required this.rawX,
    required this.rawY,
    required this.rawZ,
    this.isCalibrated = false,
    this.accuracy = 1.0,
  });

  @override
  String toString() => 'CompassData(angle: $angle, direction: $direction, isCalibrated: $isCalibrated, accuracy: $accuracy)';
}

class CompassServiceOld {
  static final CompassServiceOld _instance = CompassServiceOld._internal();
  factory CompassServiceOld() => _instance;
  CompassServiceOld._internal();

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