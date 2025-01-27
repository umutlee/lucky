import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/fortune_recommendation_service.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/study_fortune.dart';
import 'package:all_lucky/core/models/career_fortune.dart';
import 'package:all_lucky/core/models/love_fortune.dart';
import 'package:all_lucky/core/models/daily_fortune.dart';

void main() {
  late FortuneRecommendationService service;

  setUp(() {
    service = FortuneRecommendationService();
  });

  group('FortuneRecommendationService', () {
    test('generateRecommendations should return non-empty list', () {
      final fortune = Fortune(
        id: '1',
        type: FortuneType.daily,
        title: '測試運勢',
        score: 85,
        description: '今日運勢不錯',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        luckyTimes: ['早上', '下午'],
        luckyDirections: ['東', '南'],
        luckyColors: ['紅', '黃'],
        luckyNumbers: [6, 8],
        suggestions: ['多運動'],
        warnings: ['避免熬夜'],
        zodiac: Zodiac.dragon,
      );

      final recommendations = service.generateRecommendations(fortune);

      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(5));
    });

    test('generateRecommendations should handle different fortune types', () {
      final studyFortune = Fortune(
        id: '2',
        type: FortuneType.study,
        title: '學業運勢',
        score: 90,
        description: '學習效果極佳',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        luckyTimes: ['上午'],
        luckyDirections: ['東'],
        luckyColors: ['藍'],
        luckyNumbers: [3],
        suggestions: ['專注學習'],
        warnings: ['避免分心'],
        studyFortune: const StudyFortune(
          concentration: 90,
          comprehension: 85,
          memory: 88,
          creativity: 92,
          bestSubjects: ['數學', '物理'],
          challengingSubjects: ['歷史'],
          studyTips: ['早上是學習效率最佳時段'],
        ),
      );

      final recommendations = service.generateRecommendations(studyFortune);

      expect(recommendations, isNotEmpty);
      expect(
        recommendations.any((r) => r.contains('學習重點')),
        isTrue,
      );
    });

    test('generateRecommendations should handle career fortune', () {
      final careerFortune = Fortune(
        id: '3',
        type: FortuneType.career,
        title: '事業運勢',
        score: 75,
        description: '事業運平穩',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        luckyTimes: ['上午'],
        luckyDirections: ['南'],
        luckyColors: ['黑'],
        luckyNumbers: [9],
        suggestions: ['把握機會'],
        warnings: ['謹慎決策'],
        careerFortune: const CareerFortune(
          workPerformance: 80,
          teamwork: 85,
          leadership: 70,
          innovation: 75,
          opportunities: ['升遷機會'],
          challenges: ['競爭壓力'],
          careerTips: ['保持良好的團隊合作'],
          investmentTips: ['適合保守投資'],
        ),
      );

      final recommendations = service.generateRecommendations(careerFortune);

      expect(recommendations, isNotEmpty);
      expect(
        recommendations.any((r) => r.contains('職場建議')),
        isTrue,
      );
    });

    test('generateRecommendations should handle love fortune', () {
      final loveFortune = Fortune(
        id: '4',
        type: FortuneType.love,
        title: '感情運勢',
        score: 95,
        description: '桃花運旺盛',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        luckyTimes: ['晚上'],
        luckyDirections: ['西'],
        luckyColors: ['粉'],
        luckyNumbers: [2],
        suggestions: ['把握機會'],
        warnings: ['不要太衝動'],
        loveFortune: const LoveFortune(
          attraction: 90,
          communication: 85,
          understanding: 88,
          stability: 82,
          opportunities: ['遇到心儀對象'],
          challenges: ['溝通障礙'],
          relationshipTips: ['保持真誠'],
          dateTips: ['適合浪漫晚餐'],
        ),
      );

      final recommendations = service.generateRecommendations(loveFortune);

      expect(recommendations, isNotEmpty);
      expect(
        recommendations.any((r) => r.contains('感情建議')),
        isTrue,
      );
    });

    test('generateRecommendations should handle error gracefully', () {
      final invalidFortune = Fortune(
        id: '5',
        type: FortuneType.daily,
        title: '',  // 無效標題
        score: -1,  // 無效分數
        description: '',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        luckyTimes: [],
        luckyDirections: [],
        luckyColors: [],
        luckyNumbers: [],
        suggestions: [],
        warnings: [],
      );

      final recommendations = service.generateRecommendations(invalidFortune);

      expect(recommendations, isNotEmpty);
      expect(recommendations.first, equals('保持平常心，按部就班行事'));
    });

    test('generateRecommendations should include zodiac compatibility', () {
      final fortune = Fortune(
        id: '6',
        type: FortuneType.daily,
        title: '運勢測試',
        score: 80,
        description: '運勢不錯',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        luckyTimes: ['上午'],
        luckyDirections: ['東'],
        luckyColors: ['紅'],
        luckyNumbers: [8],
        suggestions: ['把握機會'],
        warnings: ['注意細節'],
        zodiac: Zodiac.dragon,
      );

      final recommendations = service.generateRecommendations(fortune);

      expect(
        recommendations.any((r) => r.contains('相配生肖')),
        isTrue,
      );
    });
  });
} 