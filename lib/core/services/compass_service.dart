import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../models/compass_direction.dart';
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
  final logger = ref.watch(loggerServiceProvider);
  return CompassService(logger);
});

class CompassService {
  final LoggerService _logger;
  StreamSubscription<dynamic>? _subscription;
  final _compassController = StreamController<CompassData>.broadcast();
  final _calibratedCompassController = StreamController<CompassData>.broadcast();
  
  // 校準相關變量
  double _calibrationOffset = 0.0;
  bool _isCalibrating = false;
  List<double> _calibrationReadings = [];
  
  // 平滑處理相關變量
  final _smoothingWindow = 5;
  final List<double> _recentAngles = [];
  double _lastAngle = 0.0;
  
  // 方位定義
  static const Map<String, (double start, double end)> _directionRanges = {
    '北': (337.5, 22.5),
    '東北': (22.5, 67.5),
    '東': (67.5, 112.5),
    '東南': (112.5, 157.5),
    '南': (157.5, 202.5),
    '西南': (202.5, 247.5),
    '西': (247.5, 292.5),
    '西北': (292.5, 337.5),
  };

  CompassService(this._logger);

  /// 獲取原始指南針數據流
  Stream<CompassData> get compassStream => _compassController.stream;
  
  /// 獲取校準後的指南針數據流
  Stream<CompassData> get calibratedCompassStream => _calibratedCompassController.stream;

  /// 開始監聽感應器數據
  void startListening() {
    try {
      _subscription = magnetometerEvents.listen((MagnetometerEvent event) {
        final rawAngle = _calculateAngle(event.x, event.y);
        final smoothedAngle = _smoothAngle(rawAngle);
        final direction = _getDirection(smoothedAngle);
        
        final data = CompassData(
          angle: smoothedAngle,
          direction: direction,
          rawX: event.x,
          rawY: event.y,
          rawZ: event.z,
          isCalibrated: !_isCalibrating,
          accuracy: _calculateAccuracy(event),
        );
        
        // 發送原始數據
        _compassController.add(data);
        
        // 處理校準
        if (_isCalibrating) {
          _processCalibrationReading(smoothedAngle);
        } else {
          // 發送校準後的數據
          final calibratedAngle = _applyCalibratedAngle(smoothedAngle);
          final calibratedDirection = _getDirection(calibratedAngle);
          final calibratedData = CompassData(
            angle: calibratedAngle,
            direction: calibratedDirection,
            rawX: event.x,
            rawY: event.y,
            rawZ: event.z,
            isCalibrated: true,
            accuracy: _calculateAccuracy(event),
          );
          _calibratedCompassController.add(calibratedData);
        }
      });
    } catch (e) {
      _logger.error('啟動指南針監聽失敗', e);
    }
  }

  /// 開始校準
  void startCalibration() {
    _isCalibrating = true;
    _calibrationReadings.clear();
    _logger.info('開始指南針校準');
  }

  /// 處理校準讀數
  void _processCalibrationReading(double angle) {
    _calibrationReadings.add(angle);
    
    // 收集足夠的樣本後完成校準
    if (_calibrationReadings.length >= 50) {
      _finishCalibration();
    }
  }

  /// 完成校準
  void _finishCalibration() {
    if (_calibrationReadings.isEmpty) return;
    
    // 計算平均偏移
    final northReadings = _calibrationReadings.where((angle) => 
      angle >= 350 || angle <= 10).toList();
    
    if (northReadings.isNotEmpty) {
      final avgReading = northReadings.reduce((a, b) => a + b) / northReadings.length;
      _calibrationOffset = avgReading <= 180 ? -avgReading : (360 - avgReading);
    }
    
    _isCalibrating = false;
    _calibrationReadings.clear();
    _logger.info('完成指南針校準，偏移量: $_calibrationOffset');
  }

  /// 取消校準
  void cancelCalibration() {
    _isCalibrating = false;
    _calibrationReadings.clear();
    _logger.info('取消指南針校準');
  }

  /// 重置校準
  void resetCalibration() {
    _calibrationOffset = 0.0;
    _logger.info('重置指南針校準');
  }

  /// 檢查是否正在校準
  bool get isCalibrating => _isCalibrating;

  /// 獲取校準偏移量
  double get calibrationOffset => _calibrationOffset;

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// 計算角度
  double _calculateAngle(double x, double y) {
    // 使用 atan2 計算角度
    double angle = math.atan2(y, x) * (180 / math.pi);
    // 標準化到 0-360 範圍
    if (angle < 0) angle += 360;
    return angle;
  }

  /// 平滑角度數據
  double _smoothAngle(double newAngle) {
    // 處理角度跳變
    if (_lastAngle != 0) {
      final diff = newAngle - _lastAngle;
      if (diff > 180) {
        newAngle -= 360;
      } else if (diff < -180) {
        newAngle += 360;
      }
    }
    
    // 添加到最近角度列表
    _recentAngles.add(newAngle);
    if (_recentAngles.length > _smoothingWindow) {
      _recentAngles.removeAt(0);
    }
    
    // 計算平均值
    final smoothedAngle = _recentAngles.reduce((a, b) => a + b) / _recentAngles.length;
    
    // 標準化到 0-360 範圍
    double normalizedAngle = smoothedAngle % 360;
    if (normalizedAngle < 0) normalizedAngle += 360;
    
    _lastAngle = normalizedAngle;
    return normalizedAngle;
  }

  /// 獲取方位
  String _getDirection(double angle) {
    // 處理北方特殊情況
    if (angle >= 337.5 || angle < 22.5) {
      return '北';
    }
    
    // 處理其他方位
    for (final entry in _directionRanges.entries) {
      final (start, end) = entry.value;
      if (angle >= start && angle < end) {
        return entry.key;
      }
    }
    
    return '北'; // 預設返回北
  }

  /// 計算校準後的角度
  double _applyCalibratedAngle(double angle) {
    double calibratedAngle = angle + _calibrationOffset;
    // 標準化到 0-360 範圍
    calibratedAngle = calibratedAngle % 360;
    if (calibratedAngle < 0) calibratedAngle += 360;
    return calibratedAngle;
  }

  /// 計算感應器精度
  double _calculateAccuracy(MagnetometerEvent event) {
    // 計算磁場強度
    final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    
    // 正常的地磁場強度範圍約為 25-65 µT
    const minMagnitude = 25.0;
    const maxMagnitude = 65.0;
    
    if (magnitude < minMagnitude || magnitude > maxMagnitude) {
      return 0.0; // 不可靠
    }
    
    // 計算可靠度得分 (0-1)
    return (magnitude - minMagnitude) / (maxMagnitude - minMagnitude);
  }

  /// 獲取吉利方位
  String getLuckyDirection(DateTime date) {
    // 根據農曆日期計算吉利方位
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    
    // 使用更複雜的算法計算吉利方位
    final baseDirections = ['東', '南', '西', '北'];
    final compoundDirections = ['東北', '東南', '西南', '西北'];
    
    // 根據日期選擇基礎方位或複合方位
    final useCompound = (dayOfYear % 2 == 0);
    final directions = useCompound ? compoundDirections : baseDirections;
    
    // 使用日期計算索引
    final index = ((dayOfYear * 3 + date.month * 5 + date.day * 7) % directions.length);
    
    return directions[index];
  }

  void dispose() {
    stopListening();
    _compassController.close();
    _calibratedCompassController.close();
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