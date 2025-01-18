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
      final direction = CompassDirection.fromDegrees(90); // 東
      final luckyDirections = ['東', '南'];

      expect(
        compassService.isLuckyDirection(direction, luckyDirections),
        isTrue,
      );

      final unluckyDirection = CompassDirection.fromDegrees(0); // 北
      expect(
        compassService.isLuckyDirection(unluckyDirection, luckyDirections),
        isFalse,
      );
    });

    test('getNearestLuckyDirection should return correct direction', () {
      final current = CompassDirection.fromDegrees(45); // 東北
      final luckyDirections = ['東', '北'];

      final nearest = compassService.getNearestLuckyDirection(
        current,
        luckyDirections,
      );

      expect(nearest, isNotNull);
      expect(nearest!.direction, equals('東'));
    });

    test('getNearestLuckyDirection should return null for empty lucky directions',
        () {
      final current = CompassDirection.fromDegrees(45);
      final nearest = compassService.getNearestLuckyDirection(
        current,
        [],
      );

      expect(nearest, isNull);
    });

    test('CompassDirection fromDegrees should handle all quadrants', () {
      final directions = {
        0.0: '北',
        45.0: '東北',
        90.0: '東',
        135.0: '東南',
        180.0: '南',
        225.0: '西南',
        270.0: '西',
        315.0: '西北',
      };

      directions.forEach((degrees, expectedDirection) {
        final direction = CompassDirection.fromDegrees(degrees);
        expect(direction.direction, equals(expectedDirection));
      });
    });

    test('CompassDirection fromDegrees should normalize angles', () {
      // 測試大於360度的角度
      final direction1 = CompassDirection.fromDegrees(450); // 450 - 360 = 90 (東)
      expect(direction1.direction, equals('東'));

      // 測試負角度
      final direction2 = CompassDirection.fromDegrees(-90); // -90 + 360 = 270 (西)
      expect(direction2.direction, equals('西'));
    });
  });
} 