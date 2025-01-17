import 'package:meta/meta.dart';
import 'user_identity.dart';

/// 運勢等級
enum FortuneLevel {
  superLucky,    // 大吉
  lucky,         // 中吉
  smallLucky,    // 小吉
  normal,        // 平
  unlucky,       // 凶
}

/// 綜合運勢模型
@immutable
class OverallFortune {
  /// 綜合指數（0-100）
  final int overallScore;
  
  /// 運勢等級
  final FortuneLevel level;
  
  /// 運勢走勢描述
  final String trendDescription;
  
  /// 今日關鍵字
  final List<String> keywords;
  
  /// 年輕人用語評語
  final String slangComment;
  
  /// 運勢顏色
  final String luckyColor;
  
  /// 運勢數字
  final int luckyNumber;
  
  /// 運勢方位
  final String luckyDirection;

  const OverallFortune({
    required this.overallScore,
    required this.level,
    required this.trendDescription,
    required this.keywords,
    required this.slangComment,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyDirection,
  });

  /// 從 JSON 創建實例
  factory OverallFortune.fromJson(Map<String, dynamic> json) {
    return OverallFortune(
      overallScore: json['overallScore'] as int,
      level: FortuneLevel.values.firstWhere(
        (e) => e.toString() == 'FortuneLevel.${json['level']}',
      ),
      trendDescription: json['trendDescription'] as String,
      keywords: List<String>.from(json['keywords']),
      slangComment: json['slangComment'] as String,
      luckyColor: json['luckyColor'] as String,
      luckyNumber: json['luckyNumber'] as int,
      luckyDirection: json['luckyDirection'] as String,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'level': level.toString().split('.').last,
      'trendDescription': trendDescription,
      'keywords': keywords,
      'slangComment': slangComment,
      'luckyColor': luckyColor,
      'luckyNumber': luckyNumber,
      'luckyDirection': luckyDirection,
    };
  }

  /// 根據用戶身份獲取特定的運勢描述
  String getIdentitySpecificDescription(UserIdentity identity) {
    final baseDescription = _getFortuneDescription(level, identity.languageStyle);
    return identity.getFortuneStyle(baseDescription);
  }

  /// 獲取運勢等級描述
  String _getFortuneDescription(FortuneLevel level, LanguageStyle style) {
    if (style == LanguageStyle.classical) {
      switch (level) {
        case FortuneLevel.superLucky:
          return '大吉 - 萬事亨通，諸事順遂';
        case FortuneLevel.lucky:
          return '中吉 - 吉祥如意，平安喜樂';
        case FortuneLevel.smallLucky:
          return '小吉 - 小有所成，漸入佳境';
        case FortuneLevel.normal:
          return '平 - 平安無事，守成為上';
        case FortuneLevel.unlucky:
          return '凶 - 諸事謹慎，靜待花開';
      }
    } else {
      switch (level) {
        case FortuneLevel.superLucky:
          return '大吉 - 今天超級 Lucky！';
        case FortuneLevel.lucky:
          return '中吉 - 運勢不錯喔！';
        case FortuneLevel.smallLucky:
          return '小吉 - 小確幸的一天';
        case FortuneLevel.normal:
          return '平 - 平平淡淡才是真';
        case FortuneLevel.unlucky:
          return '凶 - 多喝熱水保平安';
      }
    }
  }

  /// 獲取運勢描述
  String getFortuneDescription(UserIdentity identity) {
    if (identity.languageStyle == LanguageStyle.classical) {
      return '${_getFortuneDescription(level, LanguageStyle.classical)}\n${trendDescription}';
    } else {
      return getSlangDescription();
    }
  }

  /// 獲取年輕人用語版本的運勢描述
  String getSlangDescription() {
    switch (level) {
      case FortuneLevel.superLucky:
        return '這波啊，這波是天選之人！$slangComment';
      case FortuneLevel.lucky:
        return '今天狀態超 Carry！$slangComment';
      case FortuneLevel.smallLucky:
        return '小小 Lucky，心情 Good！$slangComment';
      case FortuneLevel.normal:
        return '今天普普通通，佛系就好～$slangComment';
      case FortuneLevel.unlucky:
        return '今天有點 GG，不過問題不大！$slangComment';
    }
  }

  /// 獲取運勢標籤
  List<String> getTags(LanguageStyle style) {
    if (style == LanguageStyle.classical) {
      return [
        ...keywords,
        '吉祥色：$luckyColor',
        '吉祥數：$luckyNumber',
        '吉祥方位：$luckyDirection',
      ];
    } else {
      return [
        ...keywords,
        '幸運色：$luckyColor',
        '幸運數字：$luckyNumber',
        '幸運方位：$luckyDirection',
      ];
    }
  }
} 