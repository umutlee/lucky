import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_type.dart';
import '../utils/lunar_wrapper.dart';

/// 運勢分數服務提供者
final fortuneScoreServiceProvider = Provider<FortuneScoreService>((ref) {
  return FortuneScoreService();
});

/// 運勢分數服務
class FortuneScoreService {
  /// 計算運勢分數
  ({
    int score,
    Map<String, double> factors,
    List<String> suggestions,
  }) calculateFortuneScore({
    required FortuneType type,
    required DateTime date,
    String? zodiac,
    String? targetZodiac,
  }) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
                                                                                                                                                                                                                        date.day,
    );

    // 基礎分數
    int baseScore = 60;

    // 計算各個因素的影響
    final factorsList = <({String name, int value})>[];

    // 日運勢影響
    final dayFortune = lunar.getDayFortune();
    if (dayFortune == '吉') {
      baseScore += 10;
      factorsList.add((name: '日運勢', value: 10));
    }

    // 五行相生相剋
    final dayWuxing = lunar.getDayWuXing();
    final timeWuxing = lunar.getTimeWuXing();
    if (dayWuxing == timeWuxing) {
      baseScore += 5;
      factorsList.add((name: '五行相合', value: 5));
    }

    // 根據運勢類型調整分數
    final typeScore = _calculateTypeScore(type, lunar);
    baseScore += typeScore.score;
    factorsList.addAll(typeScore.factors);

    // 生成建議
    final suggestions = _generateSuggestions(type, lunar);

    // 轉換因素列表為 Map
    final factors = Map.fromEntries(
      factorsList.map((f) => MapEntry(f.name, f.value.toDouble())),
    );

    return (
      score: baseScore.clamp(0, 100),
      factors: factors,
      suggestions: suggestions,
    );
  }

  /// 根據運勢類型計算分數
  ({
    int score,
    List<({String name, int value})> factors,
  }) _calculateTypeScore(FortuneType type, LunarWrapper lunar) {
    int score = 0;
    final factors = <({String name, int value})>[];

    switch (type) {
      case FortuneType.daily:
        final positions = lunar.getDayPositions();
        if (positions.contains('東') || positions.contains('南')) {
          score += 5;
          factors.add((name: '方位吉利', value: 5));
        }
        break;

      case FortuneType.study:
        if (lunar.getDayWuXing() == '金') {
          score += 8;
          factors.add((name: '五行有利', value: 8));
        }
        break;

      case FortuneType.career:
        final pengZuGan = lunar.getDayPengZuGan();
        if (pengZuGan == '甲' || pengZuGan == '丙') {
          score += 10;
          factors.add((name: '干支有利', value: 10));
        }
        break;

      case FortuneType.love:
        if (lunar.getDayXiu() == '角' || lunar.getDayXiu() == '心') {
          score += 12;
          factors.add((name: '二十八宿有利', value: 12));
        }
        break;

      case FortuneType.wealth:
        final positions = lunar.getDayPositions();
        if (positions.contains('東南') || positions.contains('西北')) {
          score += 15;
          factors.add((name: '財位有利', value: 15));
        }
        break;

      case FortuneType.health:
        if (lunar.getDayTaishen() == '太歲') {
          score += 8;
          factors.add((name: '太歲有利', value: 8));
        }
        break;

      case FortuneType.travel:
        final positions = lunar.getDayPositions();
        if (positions.contains('南') || positions.contains('東')) {
          score += 10;
          factors.add((name: '行程方位有利', value: 10));
        }
        break;

      case FortuneType.social:
        if (lunar.getDayXiu() == '軫' || lunar.getDayXiu() == '張') {
          score += 10;
          factors.add((name: '社交宿位有利', value: 10));
        }
        break;

      case FortuneType.creative:
        if (lunar.getDayWuXing() == '火') {
          score += 12;
          factors.add((name: '創意五行有利', value: 12));
        }
        break;
    }

    return (score: score, factors: factors);
  }

  /// 生成運勢建議
  List<String> _generateSuggestions(FortuneType type, LunarWrapper lunar) {
    final suggestions = <String>[];

    switch (type) {
      case FortuneType.daily:
        suggestions.add('今日運勢：${lunar.getDayFortune()}');
        suggestions.add('吉利方位：${lunar.getDayPositions().join('、')}');
        break;

      case FortuneType.study:
        if (lunar.getDayWuXing() == '金') {
          suggestions.add('今日適合學習金融相關知識');
        }
        suggestions.add('建議在${lunar.getDayPositions().firstOrNull ?? "書房"}方位學習');
        break;

      case FortuneType.career:
        suggestions.add('事業運勢：${lunar.getDayPengZuGan()}');
        suggestions.add('建議在${lunar.getDayPositions().firstOrNull ?? ""}方位辦公');
        break;

      case FortuneType.love:
        suggestions.add('桃花運勢：${lunar.getDayXiu()}');
        suggestions.add('宜在${lunar.getDayPositions().firstOrNull ?? ""}方向相會');
        break;

      case FortuneType.wealth:
        suggestions.add('財運提示：${lunar.getDayPengZuGan()}');
        suggestions.add('開運方位：${lunar.getDayPositions().firstOrNull ?? ""}');
        break;

      case FortuneType.health:
        suggestions.add('今日養生要點：${lunar.getDayTaishen()}');
        break;

      case FortuneType.travel:
        suggestions.add('出行建議：往${lunar.getDayPositions().firstOrNull ?? "東"}方向');
        break;

      case FortuneType.social:
        suggestions.add('人際運勢：${lunar.getDayXiu()}');
        suggestions.add('貴人方位：${lunar.getDayPositions().firstOrNull}');
        break;

      case FortuneType.creative:
        if (lunar.getDayWuXing() == '火') {
          suggestions.add('今日靈感充沛，適合創作');
        }
        suggestions.add('創意空間建議：${lunar.getDayPositions().firstOrNull ?? ""}');
        break;
    }

    return suggestions;
  }
} 