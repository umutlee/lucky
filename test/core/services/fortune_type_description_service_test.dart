import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/fortune_type_description_service.dart';
import 'package:all_lucky/core/models/fortune_type.dart';

void main() {
  late FortuneTypeDescriptionService service;

  setUp(() {
    service = FortuneTypeDescriptionService();
  });

  group('FortuneTypeDescriptionService', () {
    test('getTypeTitle returns correct title for each type', () {
      expect(service.getTypeTitle(FortuneType.daily), '每日運勢');
      expect(service.getTypeTitle(FortuneType.study), '學業運勢');
      expect(service.getTypeTitle(FortuneType.career), '事業運勢');
      expect(service.getTypeTitle(FortuneType.love), '感情運勢');
    });

    test('getTypeDescription returns non-empty description for each type', () {
      for (final type in FortuneType.values) {
        final description = service.getTypeDescription(type);
        expect(description, isNotEmpty);
        expect(description, isNot('暫無描述'));
      }
    });

    test('getTypeFeatures returns non-empty list for each type', () {
      for (final type in FortuneType.values) {
        final features = service.getTypeFeatures(type);
        expect(features, isNotEmpty);
        expect(features.length, 4); // 每種類型都有4個特點
        for (final feature in features) {
          expect(feature, isNotEmpty);
        }
      }
    });

    test('getAnalysisFactors returns non-empty list for each type', () {
      for (final type in FortuneType.values) {
        final factors = service.getAnalysisFactors(type);
        expect(factors, isNotEmpty);
        expect(factors.length, 4); // 每種類型都有4個分析因素
        for (final factor in factors) {
          expect(factor, isNotEmpty);
        }
      }
    });

    test('getSuitableScenarios returns non-empty list for each type', () {
      for (final type in FortuneType.values) {
        final scenarios = service.getSuitableScenarios(type);
        expect(scenarios, isNotEmpty);
        expect(scenarios.length, 4); // 每種類型都有4個適用場景
        for (final scenario in scenarios) {
          expect(scenario, isNotEmpty);
        }
      }
    });

    test('getTypeTips returns non-empty list for each type', () {
      for (final type in FortuneType.values) {
        final tips = service.getTypeTips(type);
        expect(tips, isNotEmpty);
        expect(tips.length, 4); // 每種類型都有4個提示
        for (final tip in tips) {
          expect(tip, isNotEmpty);
        }
      }
    });

    test('getFullDescription returns formatted string with all sections', () {
      for (final type in FortuneType.values) {
        final fullDescription = service.getFullDescription(type);
        expect(fullDescription, contains(service.getTypeTitle(type)));
        expect(fullDescription, contains(service.getTypeDescription(type)));
        
        for (final feature in service.getTypeFeatures(type)) {
          expect(fullDescription, contains(feature));
        }
        
        for (final factor in service.getAnalysisFactors(type)) {
          expect(fullDescription, contains(factor));
        }
        
        for (final scenario in service.getSuitableScenarios(type)) {
          expect(fullDescription, contains(scenario));
        }
        
        for (final tip in service.getTypeTips(type)) {
          expect(fullDescription, contains(tip));
        }
      }
    });

    group('getFortuneEvaluation', () {
      test('returns correct evaluation for different scores', () {
        final testCases = [
          (1.0, contains('大吉')),
          (0.9, contains('大吉')),
          (0.8, contains('吉')),
          (0.7, contains('小吉')),
          (0.5, contains('平')),
          (0.3, contains('小凶')),
          (0.1, contains('凶')),
        ];

        for (final (score, matcher) in testCases) {
          expect(
            service.getFortuneEvaluation(FortuneType.daily, score),
            matcher
          );
        }
      });

      test('includes type-specific advice', () {
        // 測試學業運勢的評價
        expect(
          service.getFortuneEvaluation(FortuneType.study, 0.8),
          contains('適合進行重要學習和考試')
        );
        expect(
          service.getFortuneEvaluation(FortuneType.study, 0.4),
          contains('建議調整學習計劃和方法')
        );

        // 測試事業運勢的評價
        expect(
          service.getFortuneEvaluation(FortuneType.career, 0.8),
          contains('適合推進重要工作項目')
        );
        expect(
          service.getFortuneEvaluation(FortuneType.career, 0.4),
          contains('宜穩健行事')
        );

        // 測試感情運勢的評價
        expect(
          service.getFortuneEvaluation(FortuneType.love, 0.8),
          contains('桃花運旺')
        );
        expect(
          service.getFortuneEvaluation(FortuneType.love, 0.4),
          contains('感情方面需要多加耐心')
        );
      });

      test('handles invalid scores gracefully', () {
        expect(
          () => service.getFortuneEvaluation(FortuneType.daily, -0.1),
          throwsArgumentError
        );
        expect(
          () => service.getFortuneEvaluation(FortuneType.daily, 1.1),
          throwsArgumentError
        );
      });
    });
  });
} 