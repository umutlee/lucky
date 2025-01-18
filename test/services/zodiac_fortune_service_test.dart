import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/zodiac_fortune_service.dart';
import 'package:all_lucky/core/models/fortune.dart';

void main() {
  late ZodiacFortuneService service;

  setUp(() {
    service = ZodiacFortuneService();
  });

  group('ZodiacFortuneService Tests', () {
    test('calculateZodiacAffinity returns correct affinity scores', () {
      final affinity = service.calculateZodiacAffinity('龍', '事業');

      // 檢查基礎相性分數
      expect(affinity['鼠'], 90); // 龍與鼠相配
      expect(affinity['猴'], 85); // 龍與猴相配
      
      // 檢查事業相關生肖的加成
      expect(affinity['虎'], greaterThan(40)); // 虎是事業相關生肖，應該有加成
      expect(affinity['牛'], greaterThan(60)); // 牛是事業相關生肖，應該有加成
    });

    test('generateZodiacRecommendations provides appropriate recommendations', () {
      // 測試高分情況
      final highScoreRecs = service.generateZodiacRecommendations('龍', '事業', 85);
      expect(highScoreRecs.length, 2);
      expect(highScoreRecs[0], contains('大展身手'));
      expect(highScoreRecs[1], contains('生肖特質'));

      // 測試中等分數情況
      final mediumScoreRecs = service.generateZodiacRecommendations('龍', '學習', 65);
      expect(mediumScoreRecs.length, 1);
      expect(mediumScoreRecs[0], contains('平常心'));

      // 測試低分情況
      final lowScoreRecs = service.generateZodiacRecommendations('龍', '財運', 45);
      expect(lowScoreRecs.length, 2);
      expect(lowScoreRecs[0], contains('小心'));
      expect(lowScoreRecs[1], contains('朋友協助'));
    });

    test('enhanceFortuneWithZodiac correctly enhances fortune object', () {
      final fortune = Fortune(
        id: '1',
        description: '今天運勢不錯',
        score: 85,
        type: '事業',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起工作'],
        zodiac: '',
        zodiacAffinity: {},
      );

      final enhanced = service.enhanceFortuneWithZodiac(fortune, '龍');

      expect(enhanced.zodiac, '龍');
      expect(enhanced.zodiacAffinity, isNotEmpty);
      expect(enhanced.recommendations.length, greaterThan(1));
      expect(enhanced.recommendations.first, '早起工作');
      expect(enhanced.recommendations.last, contains('生肖特質'));
    });

    test('getRelatedZodiacs returns appropriate zodiacs for different fortune types', () {
      final careerZodiacs = service.calculateZodiacAffinity('龍', '事業');
      final studyZodiacs = service.calculateZodiacAffinity('兔', '學習');
      final wealthZodiacs = service.calculateZodiacAffinity('鼠', '財運');
      final socialZodiacs = service.calculateZodiacAffinity('馬', '人際');

      // 事業運相關生肖應該有較高分數
      expect(careerZodiacs['虎'], greaterThan(70));
      expect(careerZodiacs['牛'], greaterThan(70));

      // 學習運相關生肖應該有較高分數
      expect(studyZodiacs['蛇'], greaterThan(70));
      expect(studyZodiacs['猴'], greaterThan(70));

      // 財運相關生肖應該有較高分數
      expect(wealthZodiacs['龍'], greaterThan(70));
      expect(wealthZodiacs['猴'], greaterThan(70));

      // 人際運相關生肖應該有較高分數
      expect(socialZodiacs['羊'], greaterThan(70));
      expect(socialZodiacs['豬'], greaterThan(70));
    });
  });
} 