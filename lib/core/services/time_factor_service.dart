import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import '../models/fortune_type.dart';
import '../utils/logger.dart';

/// 時間因素計算服務
final timeFactorServiceProvider = Provider<TimeFactorService>((ref) {
  final logger = Logger('TimeFactorService');
  return TimeFactorService(logger);
});

/// 時間因素服務類，用於計算各種時間因素對運勢的影響
class TimeFactorService {
  final Logger _logger;

  TimeFactorService(this._logger);

  /// 計算時間分數
  double calculateTimeScore(DateTime date, FortuneType type) {
    try {
      final lunar = Lunar.fromDate(date);
      
      // 獲取時辰
      final timeZhi = lunar.getTimeZhi();
      
      // 獲取日干支
      final dayGanZhi = '${lunar.getDayGan()}${lunar.getDayZhi()}';
      
      // 獲取當前節氣
      final jieQi = lunar.getJieQi();
      
      // 計算基礎時間分數
      var score = _calculateBaseTimeScore(lunar);
      
      // 根據時辰調整分數
      score = _adjustScoreByTimeZhi(score, timeZhi, type);
      
      // 根據日干支調整分數
      score = _adjustScoreByDayGanZhi(score, dayGanZhi, type);
      
      // 根據節氣調整分數
      if (jieQi.isNotEmpty) {
        score = _adjustScoreByJieQi(score, jieQi, type);
      }
      
      // 確保分數在 0-1 範圍內
      return score.clamp(0.0, 1.0);
    } catch (e) {
      _logger.warning('計算時間分數失敗: $e');
      return 0.7;
    }
  }

  /// 計算基礎時間分數
  double _calculateBaseTimeScore(Lunar lunar) {
    // 獲取時辰吉凶
    final dayYi = lunar.getDayYi();
    final dayJi = lunar.getDayJi();
    
    // 基礎分數 0.7
    var score = 0.7;
    
    // 根據吉凶調整分數
    score += (dayYi.length - dayJi.length) * 0.02;
    
    // 如果是吉日，加分
    if (lunar.getDayWuXing() == '金' || lunar.getDayWuXing() == '火') {
      score += 0.1;
    }
    
    return score;
  }

  /// 根據時辰調整分數
  double _adjustScoreByTimeZhi(double score, String timeZhi, FortuneType type) {
    // 各類型最佳時辰
    const bestTimeZhi = {
      FortuneType.study: ['子', '寅', '卯'],     // 深夜和早晨
      FortuneType.career: ['巳', '午', '未'],    // 上午到下午
      FortuneType.love: ['酉', '戌', '亥'],      // 傍晚到晚上
      FortuneType.wealth: ['辰', '巳', '午'],    // 早上到中午
      FortuneType.health: ['寅', '卯', '辰'],    // 早晨
      FortuneType.travel: ['巳', '午', '未'],    // 上午到下午
      FortuneType.social: ['午', '未', '申'],    // 下午到傍晚
      FortuneType.creativity: ['子', '丑', '寅'], // 深夜到早晨
      FortuneType.daily: ['寅', '卯', '辰'],     // 早晨
    };

    // 如果是最佳時辰，加分
    if (bestTimeZhi[type]?.contains(timeZhi) ?? false) {
      score += 0.2;
    }

    return score;
  }

  /// 根據日干支調整分數
  double _adjustScoreByDayGanZhi(double score, String dayGanZhi, FortuneType type) {
    // 各類型有利干支
    const favorableGanZhi = {
      FortuneType.study: ['甲子', '甲寅', '甲辰'],     // 智慧日
      FortuneType.career: ['乙巳', '丙午', '丁未'],    // 事業日
      FortuneType.love: ['丁酉', '戊戌', '己亥'],      // 桃花日
      FortuneType.wealth: ['庚辰', '辛巳', '壬午'],    // 財運日
      FortuneType.health: ['癸卯', '甲辰', '乙巳'],    // 養生日
      FortuneType.travel: ['丙午', '丁未', '戊申'],    // 出行日
      FortuneType.social: ['己未', '庚申', '辛酉'],    // 人緣日
      FortuneType.creativity: ['壬子', '癸丑', '甲寅'], // 創意日
      FortuneType.daily: ['乙卯', '丙辰', '丁巳'],     // 吉日
    };

    // 如果是有利干支，加分
    if (favorableGanZhi[type]?.contains(dayGanZhi) ?? false) {
      score += 0.15;
    }

    return score;
  }

  /// 根據節氣調整分數
  double _adjustScoreByJieQi(double score, String jieQi, FortuneType type) {
    // 各類型有利節氣
    const favorableJieQi = {
      FortuneType.study: ['立春', '驚蟄', '清明'],     // 學習好時節
      FortuneType.career: ['立夏', '小滿', '芒種'],    // 事業好時節
      FortuneType.love: ['立秋', '白露', '秋分'],      // 感情好時節
      FortuneType.wealth: ['立冬', '小雪', '大雪'],    // 財運好時節
      FortuneType.health: ['冬至', '小寒', '大寒'],    // 養生好時節
      FortuneType.travel: ['春分', '穀雨', '立夏'],    // 出遊好時節
      FortuneType.social: ['小滿', '芒種', '夏至'],    // 社交好時節
      FortuneType.creativity: ['處暑', '白露', '秋分'], // 創作好時節
      FortuneType.daily: ['雨水', '驚蟄', '清明'],     // 吉祥時節
    };

    // 如果是有利節氣，加分
    if (favorableJieQi[type]?.contains(jieQi) ?? false) {
      score += 0.1;
    }

    return score;
  }

  /// 獲取吉時
  List<String> getLuckyHours(DateTime date, FortuneType type) {
    try {
      final lunar = Lunar.fromDate(date);
      final dayYi = lunar.getDayYi();
      final timeZhi = lunar.getTimeZhi();
      
      // 根據運勢類型和日宜選擇吉時
      final luckyHours = <String>[];
      
      // 添加日宜對應的時辰
      for (final yi in dayYi) {
        if (yi.contains('開光') || yi.contains('求財')) {
          luckyHours.add('寅時 (3-5點)');
          luckyHours.add('卯時 (5-7點)');
        }
        if (yi.contains('祭祀') || yi.contains('齋醮')) {
          luckyHours.add('辰時 (7-9點)');
          luckyHours.add('巳時 (9-11點)');
        }
        if (yi.contains('修造') || yi.contains('動土')) {
          luckyHours.add('午時 (11-13點)');
          luckyHours.add('未時 (13-15點)');
        }
      }
      
      // 如果沒有從日宜獲得吉時，使用當前時辰
      if (luckyHours.isEmpty) {
        luckyHours.add('$timeZhi時');
      }
      
      return luckyHours;
    } catch (e) {
      _logger.warning('獲取吉時失敗: $e');
      return ['寅時 (3-5點)', '卯時 (5-7點)', '辰時 (7-9點)'];
    }
  }

  /// 獲取時間建議
  List<String> getTimeAdvice(DateTime date, FortuneType type) {
    try {
      final lunar = Lunar.fromDate(date);
      final suggestions = <String>[];
      
      // 添加時辰建議
      suggestions.add('今日吉時：${getLuckyHours(date, type).join("、")}');
      
      // 添加方位建議
      final positions = lunar.getDayPositions();
      if (positions.isNotEmpty) {
        suggestions.add('吉利方位：${positions.take(2).join("、")}');
      }
      
      // 添加禁忌建議
      final dayJi = lunar.getDayJi();
      if (dayJi.isNotEmpty) {
        suggestions.add('避免：${dayJi.take(2).join("、")}');
      }
      
      // 添加特定類型建議
      switch (type) {
        case FortuneType.study:
          suggestions.add('建議在${lunar.getDayPositions().firstOrNull ?? "書房"}方位學習');
          
        case FortuneType.career:
          suggestions.add('適合在${lunar.getDayPositions().firstOrNull ?? ""}方位辦公');
          
        case FortuneType.love:
          suggestions.add('宜在${lunar.getDayPositions().firstOrNull ?? ""}方向相會');
          
        case FortuneType.wealth:
          suggestions.add('財位在${lunar.getDayPositions().firstOrNull ?? ""}方向');
          
        case FortuneType.health:
          suggestions.add('建議在${lunar.getDayPositions().firstOrNull ?? ""}方位運動');
          
        case FortuneType.travel:
          suggestions.add('適合往${lunar.getDayPositions().firstOrNull ?? ""}方向出行');
          
        case FortuneType.social:
          suggestions.add('社交場所選在${lunar.getDayPositions().firstOrNull ?? ""}方位');
          
        case FortuneType.creativity:
          suggestions.add('創作靈感來自${lunar.getDayPositions().firstOrNull ?? ""}方向');
          
        case FortuneType.daily:
          suggestions.add('開運建議：${lunar.getDayYi().firstOrNull ?? "平和心態"}');
      }
      
      return suggestions;
    } catch (e) {
      _logger.warning('獲取時間建議失敗: $e');
      return ['請在吉時行事', '注意作息規律'];
    }
  }
} 