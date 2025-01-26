import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../lib/core/services/compass_service.dart';
import '../../lib/core/models/compass_direction.dart';

@GenerateMocks([Geolocator, FlutterCompass])
void main() {
  group('CompassService Tests', () {
    late CompassService compassService;

    setUp(() {
      compassService = CompassService();
    });

    test('calculateBearing should return correct angle', () {
      // 測試從東京到北京的方位角
      final bearing = compassService.calculateBearing(
        35.6762, // 東京緯度
        139.6503, // 東京經度
        39.9042, // 北京緯度
        116.4074, // 北京經度
      );

      // 方位角應該在280-290度之間（大致為西北方向）
      expect(bearing, inInclusiveRange(280, 290));
    });

    test('isLuckyDirection should correctly identify lucky directions', () {
      final direction = CompassDirection.getDirection(90); // 東
      final luckyDirections = ['東', '南'];

      expect(
        compassService.isLuckyDirection(direction, luckyDirections),
        isTrue,
      );

      final unluckyDirection = CompassDirection.getDirection(0); // 北
      expect(
        compassService.isLuckyDirection(unluckyDirection, luckyDirections),
        isFalse,
      );
    });

    test('getNearestLuckyDirection should return correct direction', () {
      final current = CompassDirection.getDirection(45); // 東北
      final luckyDirections = ['東', '北'];

      final nearest = compassService.getNearestLuckyDirection(
        current,
        luckyDirections,
      );

      expect(nearest.name, equals('東'));
    });

    test('getDirectionFromDegrees should return correct direction', () {
      final direction = CompassDirection.getDirection(90);
      expect(direction.name, equals('東'));

      final direction2 = CompassDirection.getDirection(180);
      expect(direction2.name, equals('南'));

      final direction3 = CompassDirection.getDirection(270);
      expect(direction3.name, equals('西'));

      final direction4 = CompassDirection.getDirection(0);
      expect(direction4.name, equals('北'));
    });
  });
} 