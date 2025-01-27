import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../models/fortune_type.dart';

final fortuneTypeDescriptionServiceProvider = Provider<FortuneTypeDescriptionService>((ref) {
  return FortuneTypeDescriptionService();
});

/// 運勢類型描述服務類，用於提供各種運勢類型的詳細描述
class FortuneTypeDescriptionService {
  final _logger = Logger('FortuneTypeDescriptionService');

  /// 運勢類型的詳細描述
  static const Map<FortuneType, Map<String, dynamic>> _typeDescriptions = {
    FortuneType.daily: {
      'title': '每日運勢',
      'description': '反映今日整體運勢走向，包含各方面的綜合評估。',
      'features': [
        '全方位運勢評估',
        '24小時運勢變化',
        '重要時段提醒',
        '日常活動建議'
      ],
      'analysisFactors': [
        '時辰吉凶',
        '日期五行',
        '月相變化',
        '節氣影響'
      ],
      'suitableScenarios': [
        '日常生活規劃',
        '時間安排參考',
        '活動開展建議',
        '重要決策參考'
      ],
      'tips': [
        '注意每日運勢的高峰和低谷時段',
        '根據運勢變化調整活動安排',
        '重要事項盡量安排在高運時段',
        '低運時段注意避險'
      ]
    },
    FortuneType.study: {
      'title': '學業運勢',
      'description': '專注於學習、考試、研究等學術相關活動的運勢評估。',
      'features': [
        '學習效率預測',
        '考試運勢評估',
        '記憶力指數',
        '專注度分析'
      ],
      'analysisFactors': [
        '思維敏捷度',
        '記憶力強度',
        '理解力水平',
        '考試時機'
      ],
      'suitableScenarios': [
        '考試準備',
        '課業規劃',
        '研究工作',
        '技能學習'
      ],
      'tips': [
        '選擇適合的時段進行重點學習',
        '考試前注意休息和調整',
        '配合運勢安排複習計劃',
        '保持良好的學習心態'
      ]
    },
    FortuneType.career: {
      'title': '事業運勢',
      'description': '關於工作、事業發展、商業機會等方面的運勢預測。',
      'features': [
        '工作效率指數',
        '事業機遇評估',
        '人際關係運勢',
        '決策時機分析'
      ],
      'analysisFactors': [
        '工作狀態',
        '人際互動',
        '決策時機',
        '發展機會'
      ],
      'suitableScenarios': [
        '工作規劃',
        '商業談判',
        '團隊合作',
        '職業發展'
      ],
      'tips': [
        '把握有利時機推進重要項目',
        '注意維護職場人際關係',
        '適時尋求合作機會',
        '保持職業競爭力'
      ]
    },
    FortuneType.love: {
      'title': '感情運勢',
      'description': '針對戀愛、婚姻、人際關係等情感方面的運勢分析。',
      'features': [
        '桃花指數',
        '緣分機率',
        '感情穩定度',
        '溝通順暢度'
      ],
      'analysisFactors': [
        '感情狀態',
        '緣分時機',
        '人際吸引力',
        '情感穩定性'
      ],
      'suitableScenarios': [
        '戀愛交往',
        '婚姻生活',
        '人際互動',
        '情感修復'
      ],
      'tips': [
        '把握良好桃花時機',
        '維護感情穩定發展',
        '注意溝通方式和技巧',
        '保持良好的情緒狀態'
      ]
    }
  };

  /// 獲取運勢類型的標題
  String getTypeTitle(FortuneType type) {
    try {
      return _typeDescriptions[type]?['title'] as String? ?? '未知運勢';
    } catch (e) {
      _logger.warning('獲取運勢類型標題失敗: $e');
      return '未知運勢';
    }
  }

  /// 獲取運勢類型的描述
  String getTypeDescription(FortuneType type) {
    try {
      return _typeDescriptions[type]?['description'] as String? ?? '暫無描述';
    } catch (e) {
      _logger.warning('獲取運勢類型描述失敗: $e');
      return '暫無描述';
    }
  }

  /// 獲取運勢類型的特點列表
  List<String> getTypeFeatures(FortuneType type) {
    try {
      return (_typeDescriptions[type]?['features'] as List<dynamic>?)
          ?.cast<String>() ?? [];
    } catch (e) {
      _logger.warning('獲取運勢類型特點失敗: $e');
      return [];
    }
  }

  /// 獲取運勢分析因素列表
  List<String> getAnalysisFactors(FortuneType type) {
    try {
      return (_typeDescriptions[type]?['analysisFactors'] as List<dynamic>?)
          ?.cast<String>() ?? [];
    } catch (e) {
      _logger.warning('獲取運勢分析因素失敗: $e');
      return [];
    }
  }

  /// 獲取適用場景列表
  List<String> getSuitableScenarios(FortuneType type) {
    try {
      return (_typeDescriptions[type]?['suitableScenarios'] as List<dynamic>?)
          ?.cast<String>() ?? [];
    } catch (e) {
      _logger.warning('獲取適用場景失敗: $e');
      return [];
    }
  }

  /// 獲取運勢提示列表
  List<String> getTypeTips(FortuneType type) {
    try {
      return (_typeDescriptions[type]?['tips'] as List<dynamic>?)
          ?.cast<String>() ?? [];
    } catch (e) {
      _logger.warning('獲取運勢提示失敗: $e');
      return [];
    }
  }

  /// 獲取完整的運勢描述
  String getFullDescription(FortuneType type) {
    try {
      final title = getTypeTitle(type);
      final description = getTypeDescription(type);
      final features = getTypeFeatures(type);
      final factors = getAnalysisFactors(type);
      final scenarios = getSuitableScenarios(type);
      final tips = getTypeTips(type);

      return '''
$title

${description}

特點：
${features.map((e) => '• $e').join('\n')}

分析因素：
${factors.map((e) => '• $e').join('\n')}

適用場景：
${scenarios.map((e) => '• $e').join('\n')}

運勢提示：
${tips.map((e) => '• $e').join('\n')}
''';
    } catch (e) {
      _logger.warning('獲取完整運勢描述失敗: $e');
      return '暫無完整描述';
    }
  }

  /// 根據分數獲取運勢評價
  String getFortuneEvaluation(FortuneType type, double score) {
    try {
      if (score < 0.0 || score > 1.0) {
        throw ArgumentError('分數必須在 0.0 到 1.0 之間');
      }

      final baseEvaluation = switch (score) {
        >= 0.9 => '大吉',
        >= 0.8 => '吉',
        >= 0.7 => '小吉',
        >= 0.5 => '平',
        >= 0.3 => '小凶',
        _ => '凶'
      };

      final typeSpecificAdvice = switch (type) {
        FortuneType.study when score >= 0.7 => '適合進行重要學習和考試',
        FortuneType.study => '建議調整學習計劃和方法',
        FortuneType.career when score >= 0.7 => '適合推進重要工作項目',
        FortuneType.career => '宜穩健行事，避免冒險',
        FortuneType.love when score >= 0.7 => '桃花運旺，適合發展感情',
        FortuneType.love => '感情方面需要多加耐心',
        _ when score >= 0.7 => '整體運勢良好，可以大展拳腳',
        _ => '凡事宜謹慎，注意避險'
      };

      return '$baseEvaluation - $typeSpecificAdvice';
    } catch (e) {
      _logger.warning('獲取運勢評價失敗: $e');
      return '運勢評價生成失敗';
    }
  }
} 