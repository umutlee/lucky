import 'package:meta/meta.dart';

/// 運勢類型枚舉
@immutable
enum FortuneType {
  daily,
  love,
  career,
  wealth,
  health,
  study,
  travel,
  social,
  creativity;

  String get displayName {
    switch (this) {
      case FortuneType.daily:
        return '每日運勢';
      case FortuneType.love:
        return '愛情運勢';
      case FortuneType.career:
        return '事業運勢';
      case FortuneType.wealth:
        return '財運';
      case FortuneType.health:
        return '健康運勢';
      case FortuneType.study:
        return '學業運勢';
      case FortuneType.travel:
        return '旅行運勢';
      case FortuneType.social:
        return '人際運勢';
      case FortuneType.creativity:
        return '創意運勢';
    }
  }

  String get description {
    switch (this) {
      case FortuneType.daily:
        return '查看今日整體運勢';
      case FortuneType.love:
        return '了解感情發展和桃花運';
      case FortuneType.career:
        return '職場發展和工作機會';
      case FortuneType.wealth:
        return '財運和投資機會';
      case FortuneType.health:
        return '身心健康和養生建議';
      case FortuneType.study:
        return '學習進展和考試運勢';
      case FortuneType.travel:
        return '出行運勢和旅遊建議';
      case FortuneType.social:
        return '人際關係和社交運勢';
      case FortuneType.creativity:
        return '創意靈感和藝術表現';
    }
  }

  String get iconPath {
    switch (this) {
      case FortuneType.daily:
        return 'assets/icons/daily.png';
      case FortuneType.love:
        return 'assets/icons/love.png';
      case FortuneType.career:
        return 'assets/icons/career.png';
      case FortuneType.wealth:
        return 'assets/icons/wealth.png';
      case FortuneType.health:
        return 'assets/icons/health.png';
      case FortuneType.study:
        return 'assets/icons/study.png';
      case FortuneType.travel:
        return 'assets/icons/travel.png';
      case FortuneType.social:
        return 'assets/icons/social.png';
      case FortuneType.creativity:
        return 'assets/icons/creativity.png';
    }
  }

  /// 獲取運勢類型的詳細描述
  String get detailedDescription => description;

  /// 檢查是否為日常決策類型
  bool get isDaily => this == daily;

  /// 檢查是否為學習職業類型
  bool get isCareer => this == career;

  /// 檢查是否為人際互動類型
  bool get isSocial => this == love;

  /// 檢查是否為生活休閒類型
  bool get isLifestyle => this == study;

  /// 獲取運勢類型的分類名稱
  String get categoryName {
    switch (this) {
      case FortuneType.daily:
        return '日常決策';
      case FortuneType.career:
        return '職場發展';
      case FortuneType.study:
        return '學習進修';
      case FortuneType.love:
        return '感情生活';
      case FortuneType.wealth:
        return '財富運勢';
      case FortuneType.health:
        return '健康養生';
      case FortuneType.travel:
        return '旅行出遊';
      case FortuneType.social:
        return '社交人際';
      case FortuneType.creativity:
        return '創意靈感';
    }
  }

  /// 獲取運勢建議的參考依據
  String get referenceBase {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('參考依據：');
    
    // 添加傳統依據（黃曆）
    buffer.writeln('• 傳統黃曆：節氣、五行');
    
    // 根據類型添加特定依據
    switch (this) {
      case FortuneType.daily:
        buffer.writeln('• 傳統宜忌');
        buffer.writeln('• 方位五行');
        break;
        
      case FortuneType.study:
        buffer.writeln('• 文昌位');
        buffer.writeln('• 學業運勢');
        break;
        
      case FortuneType.career:
        buffer.writeln('• 事業運勢');
        buffer.writeln('• 財運指數');
        break;
        
      case FortuneType.love:
        buffer.writeln('• 桃花運勢');
        buffer.writeln('• 姻緣指數');
        break;

      case FortuneType.wealth:
        buffer.writeln('• 財運指數');
        buffer.writeln('• 投資運勢');
        break;

      case FortuneType.health:
        buffer.writeln('• 養生指南');
        buffer.writeln('• 健康運勢');
        break;

      case FortuneType.travel:
        buffer.writeln('• 出行運勢');
        buffer.writeln('• 方位指引');
        break;

      case FortuneType.social:
        buffer.writeln('• 人際運勢');
        buffer.writeln('• 貴人指引');
        break;

      case FortuneType.creativity:
        buffer.writeln('• 靈感指數');
        buffer.writeln('• 創意運勢');
        break;
    }
    
    // 添加現代參考（星座）
    buffer.writeln('• 星座參考：當日星象');
    
    return buffer.toString().trim();
  }

  /// 從字符串創建運勢類型
  static FortuneType fromString(String value) {
    return FortuneType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FortuneType.daily,
    );
  }

  bool get isBasicType => this == daily;
  bool get isSpecialType => this != daily;
}

/// 運勢類型字符串擴展
extension FortuneTypeExtension on String {
  /// 檢查是否為基本運勢類型
  bool get isBasicType {
    return toLowerCase() == FortuneType.daily.name.toLowerCase();
  }

  /// 檢查是否為特殊運勢類型
  bool get isSpecialType {
    final lowerValue = toLowerCase();
    return [
      FortuneType.study.name.toLowerCase(),
      FortuneType.career.name.toLowerCase(),
      FortuneType.love.name.toLowerCase(),
    ].contains(lowerValue);
  }
} 