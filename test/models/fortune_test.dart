import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/fortune.dart';

void main() {
  group('Fortune Model Tests', () {
    test('creates Fortune instance with all required fields', () {
      final fortune = Fortune(
        id: '1',
        description: '今天運勢不錯',
        score: 80,
        type: '學習',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起學習', '閱讀新書'],
        zodiac: '龍',
        zodiacAffinity: {
          '鼠': 90,
          '猴': 85,
          '雞': 70,
        },
      );

      expect(fortune.id, '1');
      expect(fortune.description, '今天運勢不錯');
      expect(fortune.score, 80);
      expect(fortune.type, '學習');
      expect(fortune.date, DateTime(2024, 1, 1));
      expect(fortune.recommendations, ['早起學習', '閱讀新書']);
      expect(fortune.zodiac, '龍');
      expect(fortune.zodiacAffinity['鼠'], 90);
      expect(fortune.zodiacAffinity['猴'], 85);
      expect(fortune.zodiacAffinity['雞'], 70);
    });

    test('copyWith creates new instance with updated fields', () {
      final fortune = Fortune(
        id: '1',
        description: '今天運勢不錯',
        score: 80,
        type: '學習',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起學習', '閱讀新書'],
        zodiac: '龍',
        zodiacAffinity: {'鼠': 90},
      );

      final newFortune = fortune.copyWith(
        score: 85,
        zodiacAffinity: {'鼠': 95},
      );

      expect(newFortune.id, fortune.id);
      expect(newFortune.score, 85);
      expect(newFortune.zodiacAffinity['鼠'], 95);
    });

    test('toJson converts Fortune to JSON format', () {
      final fortune = Fortune(
        id: '1',
        description: '今天運勢不錯',
        score: 80,
        type: '學習',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起學習', '閱讀新書'],
        zodiac: '龍',
        zodiacAffinity: {'鼠': 90},
      );

      final json = fortune.toJson();

      expect(json['id'], '1');
      expect(json['description'], '今天運勢不錯');
      expect(json['score'], 80);
      expect(json['type'], '學習');
      expect(json['date'], '2024-01-01T00:00:00.000');
      expect(json['recommendations'], ['早起學習', '閱讀新書']);
      expect(json['zodiac'], '龍');
      expect(json['zodiacAffinity'], {'鼠': 90});
    });

    test('fromJson creates Fortune from JSON format', () {
      final json = {
        'id': '1',
        'description': '今天運勢不錯',
        'score': 80,
        'type': '學習',
        'date': '2024-01-01T00:00:00.000',
        'recommendations': ['早起學習', '閱讀新書'],
        'zodiac': '龍',
        'zodiacAffinity': {'鼠': 90},
      };

      final fortune = Fortune.fromJson(json);

      expect(fortune.id, '1');
      expect(fortune.description, '今天運勢不錯');
      expect(fortune.score, 80);
      expect(fortune.type, '學習');
      expect(fortune.date, DateTime(2024, 1, 1));
      expect(fortune.recommendations, ['早起學習', '閱讀新書']);
      expect(fortune.zodiac, '龍');
      expect(fortune.zodiacAffinity['鼠'], 90);
    });

    test('equality comparison works correctly', () {
      final fortune1 = Fortune(
        id: '1',
        description: '今天運勢不錯',
        score: 80,
        type: '學習',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起學習'],
        zodiac: '龍',
        zodiacAffinity: {'鼠': 90},
      );

      final fortune2 = Fortune(
        id: '1',
        description: '今天運勢不錯',
        score: 80,
        type: '學習',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起學習'],
        zodiac: '龍',
        zodiacAffinity: {'鼠': 90},
      );

      expect(fortune1, fortune2);
      expect(fortune1.hashCode, fortune2.hashCode);
    });
  });
} 