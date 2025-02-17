import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_type.dart';
import '../utils/lunar_wrapper.dart';

/// 時間因素服務提供者
final timeFactorServiceProvider = Provider<TimeFactorService>((ref) {
  return TimeFactorService();
});

/// 時間因素服務
class TimeFactorService {
  /// 計算時間因素分數
  ({
    int score,
    List<({String name, int value})> factors,
    List<String> suggestions,
  }) calculateTimeScore(DateTime date, FortuneType type) {
    final lunar = LunarWrapper.fromSolar(
      date.year,
      date.month,
      date.day,
    );

    // 基礎分數
    int baseScore = 60;

    // 計算各個因素的影響
    final factors = <({String name, int value})>[];

    // 五行相生相剋
    if (lunar.getDayWuXing() == '金' || lunar.getDayWuXing() == '火') {
      baseScore += 10;
      factors.add((name: '五行有利', value: 10));
    }

    // 根據時辰調整分數
    final timeScore = _calculateTimeScore(date, type);
    baseScore += timeScore.score;
    factors.addAll(timeScore.factors);

    // 生成建議
    final suggestions = _generateSuggestions(type, lunar);

    return (
      score: baseScore.clamp(0, 100),
      factors: factors,
      suggestions: suggestions,
    );
  }

  /// 根據時辰計算分數
  ({
    int score,
    List<({String name, int value})> factors,
  }) _calculateTimeScore(DateTime date, FortuneType type) {
    int score = 0;
    final factors = <({String name, int value})>[];

    // 根據運勢類型定義吉時
    final luckyHours = switch (type) {
      FortuneType.daily => ['子', '午', '卯'], // 早晚和中午
      FortuneType.study => ['寅', '卯', '辰'], // 早上
      FortuneType.career => ['巳', '午', '未'], // 中午
      FortuneType.love => ['酉', '戌', '亥'], // 晚上
      FortuneType.wealth => ['辰', '巳', '午'], // 上午到中午
      FortuneType.health => ['寅', '卯', '辰'], // 早上
      FortuneType.travel => ['巳', '午', '未'], // 中午
      FortuneType.social => ['申', '酉', '戌'], // 下午到晚上
      FortuneType.creative => ['子', '丑', '寅'], // 深夜到早晨
    };

    // 根據運勢類型定義吉日
    final luckyDays = switch (type) {
      FortuneType.daily => ['甲子', '丙午', '戊寅'], // 基礎吉日
      FortuneType.study => ['甲寅', '丙辰', '戊午'], // 學習日
      FortuneType.career => ['甲午', '丙申', '戊戌'], // 事業日
      FortuneType.love => ['乙卯', '丁巳', '己未'], // 桃花日
      FortuneType.wealth => ['甲辰', '丙午', '戊申'], // 財運日
      FortuneType.health => ['甲寅', '丙辰', '戊午'], // 養生日
      FortuneType.travel => ['乙巳', '丁未', '己酉'], // 出行日
      FortuneType.social => ['甲申', '丙戌', '戊子'], // 社交日
      FortuneType.creative => ['壬子', '癸丑', '甲寅'], // 創意日
    };

    // 根據運勢類型定義吉月
    final luckyMonths = switch (type) {
      FortuneType.daily => ['正月', '五月', '九月'], // 基礎吉月
      FortuneType.study => ['二月', '八月', '十月'], // 學習月
      FortuneType.career => ['三月', '七月', '十一月'], // 事業月
      FortuneType.love => ['四月', '八月', '十二月'], // 桃花月
      FortuneType.wealth => ['一月', '五月', '九月'], // 財運月
      FortuneType.health => ['三月', '七月', '十一月'], // 養生月
      FortuneType.travel => ['二月', '六月', '十月'], // 出行月
      FortuneType.social => ['四月', '八月', '十二月'], // 社交月
      FortuneType.creative => ['處暑', '白露', '秋分'], // 創作好時節
    };

    // 檢查當前時辰是否為吉時
    final currentHour = date.hour;
    if (currentHour >= 5 && currentHour < 7) {
      score += 5;
      factors.add((name: '晨運時段', value: 5));
    }

    // 檢查當前日期是否為吉日
    if (date.day % 2 == 0) {
      score += 8;
      factors.add((name: '吉日', value: 8));
    }

    // 檢查當前月份是否為吉月
    if (date.month % 3 == 0) {
      score += 10;
      factors.add((name: '吉月', value: 10));
    }

    return (score: score, factors: factors);
  }

  /// 生成時間建議
  List<String> _generateSuggestions(FortuneType type, LunarWrapper lunar) {
    final suggestions = <String>[];

    // 獲取方位建議
    final positions = lunar.getDayPositions();

    switch (type) {
      case FortuneType.daily:
        suggestions.add('今日吉時：早上6點至8點');
        suggestions.add('建議在${positions.firstOrNull ?? ""}方位活動');
        break;

      case FortuneType.study:
        suggestions.add('建議在${positions.firstOrNull ?? "書房"}方位學習');
        break;

      case FortuneType.career:
        suggestions.add('適合在${positions.firstOrNull ?? ""}方位辦公');
        break;

      case FortuneType.love:
        suggestions.add('宜在${positions.firstOrNull ?? ""}方向相會');
        break;

      case FortuneType.wealth:
        suggestions.add('財位在${positions.firstOrNull ?? ""}方向');
        break;

      case FortuneType.health:
        suggestions.add('建議在${positions.firstOrNull ?? ""}方位運動');
        break;

      case FortuneType.travel:
        suggestions.add('適合往${positions.firstOrNull ?? ""}方向出行');
        break;

      case FortuneType.social:
        suggestions.add('社交場所選在${positions.firstOrNull ?? ""}方位');
        break;

      case FortuneType.creative:
        suggestions.add('創作靈感來自${positions.firstOrNull ?? ""}方向');
        break;
    }

    return suggestions;
  }
} 