import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/zodiac.dart';

void main() {
  group('生肖測試', () {
    test('從字符串轉換為生肖', () {
      expect(Zodiac.fromString('鼠'), equals(Zodiac.rat));
      expect(Zodiac.fromString('牛'), equals(Zodiac.ox));
      expect(Zodiac.fromString('虎'), equals(Zodiac.tiger));
    });

    test('無效輸入返回默認值', () {
      expect(Zodiac.fromString('invalid'), equals(Zodiac.rat));
    });

    test('生肖描述不為空', () {
      for (final zodiac in Zodiac.values) {
        expect(zodiac.description, isNotEmpty);
      }
    });

    test('生肖五行屬性正確', () {
      expect(Zodiac.rat.element, isNotEmpty);
      expect(Zodiac.ox.element, isNotEmpty);
      expect(Zodiac.tiger.element, isNotEmpty);
    });

    test('生肖地支正確', () {
      expect(Zodiac.rat.earthlyBranch, equals('子'));
      expect(Zodiac.ox.earthlyBranch, equals('丑'));
      expect(Zodiac.tiger.earthlyBranch, equals('寅'));
    });

    test('生肖名稱正確', () {
      expect(Zodiac.rat.name, equals('鼠'));
      expect(Zodiac.ox.name, equals('牛'));
      expect(Zodiac.tiger.name, equals('虎'));
    });

    test('生肖順序正確', () {
      final zodiacs = Zodiac.values;
      expect(zodiacs[0], equals(Zodiac.rat));
      expect(zodiacs[1], equals(Zodiac.ox));
      expect(zodiacs[2], equals(Zodiac.tiger));
    });

    test('生肖toString方法正確', () {
      expect(Zodiac.rat.toString(), contains('鼠'));
      expect(Zodiac.ox.toString(), contains('牛'));
      expect(Zodiac.tiger.toString(), contains('虎'));
    });
  });
} 