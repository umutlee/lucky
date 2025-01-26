import 'package:meta/meta.dart';

/// 運勢類型枚舉
@immutable
enum FortuneType {
  daily('每日運勢', '每日綜合運勢預測'),    
  study('學業運勢', '學習發展指引'),    
  career('事業運勢', '職場發展指引'),   
  love('感情運勢', '感情發展指引');     

  final String displayName;
  final String description;
  const FortuneType(this.displayName, this.description);

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

  /// 獲取運勢類型的圖標路徑
  String get iconPath => 'assets/icons/fortune_${name.toLowerCase()}.png';

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