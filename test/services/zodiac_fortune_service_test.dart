import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/zodiac_fortune_service.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

void main() {
  group('生肖運勢服務測試', () {
    late ZodiacFortuneService service;

    setUp(() {
      service = ZodiacFortuneService();
    });

    test('計算生肖相性', () {
      final affinity = service.calculateZodiacAffinity('龍', FortuneType.career);
      expect(affinity, isA<double>());
      expect(affinity, inInclusiveRange(0.0, 100.0));
    });

    test('生成生肖運勢建議 - 高分', () {
      final highScoreRecs = service.generateZodiacRecommendations(
        '龍',
        FortuneType.career,
        85.0,
      );
      expect(highScoreRecs, isA<List<String>>());
      expect(highScoreRecs, isNotEmpty);
      expect(highScoreRecs.every((rec) => rec.isNotEmpty), isTrue);
    });

    test('生成生肖運勢建議 - 低分', () {
      final lowScoreRecs = service.generateZodiacRecommendations(
        '龍',
        FortuneType.career,
        45.0,
      );
      expect(lowScoreRecs, isA<List<String>>());
      expect(lowScoreRecs, isNotEmpty);
      expect(lowScoreRecs.every((rec) => rec.isNotEmpty), isTrue);
    });

    test('獲取生肖特質', () {
      final traits = service.getZodiacTraits('龍');
      expect(traits, isA<Map<String, dynamic>>());
      expect(traits.keys, containsAll(['personality', 'strengths', 'weaknesses']));
      expect(traits['personality'], isA<List<String>>());
      expect(traits['strengths'], isA<List<String>>());
      expect(traits['weaknesses'], isA<List<String>>());
    });

    test('獲取生肖相配', () {
      final matches = service.getZodiacMatches('龍');
      expect(matches, isA<List<String>>());
      expect(matches, isNotEmpty);
      expect(matches.every((match) => match.isNotEmpty), isTrue);
    });

    test('獲取生肖相沖', () {
      final conflicts = service.getZodiacConflicts('龍');
      expect(conflicts, isA<List<String>>());
      expect(conflicts, isNotEmpty);
      expect(conflicts.every((conflict) => conflict.isNotEmpty), isTrue);
    });

    test('獲取生肖運勢', () {
      final fortune = service.getZodiacFortune('龍', FortuneType.career);
      expect(fortune, isA<Map<String, dynamic>>());
      expect(fortune.keys, containsAll(['score', 'advice', 'luckyElements']));
      expect(fortune['score'], isA<double>());
      expect(fortune['score'], inInclusiveRange(0.0, 100.0));
      expect(fortune['advice'], isA<List<String>>());
      expect(fortune['luckyElements'], isA<Map<String, List<String>>>());
    });

    test('檢查無效生肖輸入', () {
      expect(
        () => service.calculateZodiacAffinity('無效生肖', FortuneType.career),
        throwsArgumentError,
      );
    });

    test('檢查所有運勢類型', () {
      final allTypes = FortuneType.values;
      for (final type in allTypes) {
        final fortune = service.getZodiacFortune('龍', type);
        expect(fortune, isA<Map<String, dynamic>>());
        expect(fortune['score'], inInclusiveRange(0.0, 100.0));
      }
    });
  });
} 