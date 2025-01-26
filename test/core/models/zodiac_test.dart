import 'package:test/test.dart';
import 'package:all_lucky/core/models/zodiac.dart';

void main() {
  group('Zodiac', () {
    test('fromString returns correct zodiac for valid input', () {
      expect(Zodiac.fromString('鼠'), equals(Zodiac.rat));
      expect(Zodiac.fromString('牛'), equals(Zodiac.ox));
      expect(Zodiac.fromString('虎'), equals(Zodiac.tiger));
    });

    test('fromString returns default for invalid input', () {
      expect(Zodiac.fromString('invalid'), equals(Zodiac.rat));
    });

    test('toJson returns correct map', () {
      final json = Zodiac.rat.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['name'], equals('鼠'));
      expect(json['earthlyBranch'], equals('子'));
    });

    test('fromJson returns correct zodiac', () {
      final json = {'name': '鼠', 'earthlyBranch': '子'};
      expect(Zodiac.fromJson(json), equals(Zodiac.rat));
    });

    test('description is not empty for all zodiacs', () {
      for (final zodiac in Zodiac.values) {
        expect(zodiac.description, isNotEmpty);
      }
    });

    test('element returns correct value', () {
      expect(Zodiac.rat.element, isNotEmpty);
      expect(Zodiac.ox.element, isNotEmpty);
      expect(Zodiac.tiger.element, isNotEmpty);
    });

    test('direction returns correct value', () {
      expect(Zodiac.rat.direction, isNotEmpty);
      expect(Zodiac.ox.direction, isNotEmpty);
      expect(Zodiac.tiger.direction, isNotEmpty);
    });

    test('season returns correct value', () {
      expect(Zodiac.rat.season, isNotEmpty);
      expect(Zodiac.ox.season, isNotEmpty);
      expect(Zodiac.tiger.season, isNotEmpty);
    });

    test('time returns correct value', () {
      expect(Zodiac.rat.time, isNotEmpty);
      expect(Zodiac.ox.time, isNotEmpty);
      expect(Zodiac.tiger.time, isNotEmpty);
    });
  });
} 