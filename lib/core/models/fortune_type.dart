import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune_type.freezed.dart';
part 'fortune_type.g.dart';

/// 運勢類型枚舉
enum FortuneType {
  // 日常決策
  daily('今日運勢', '今日綜合運勢預測'),
  timing('時機運勢', '重要決策時機判斷'),
  activity('活動運勢', '日常活動建議'),
  direction('方位運勢', '行動方位建議'),
  
  // 學習職業
  study('學習運勢', '學習發展指引'),
  work('工作運勢', '職場發展指引'),
  programming('編程運勢', '程式開發指引'),
  creative('創作運勢', '創意發展指引'),
  
  // 人際互動
  social('人際運勢', '社交互動指引'),
  relationship('緣分運勢', '感情發展指引'),
  cooperation('合作運勢', '團隊協作指引'),
  
  // 生活休閒
  health('健康運勢', '健康生活指引'),
  entertainment('娛樂運勢', '休閒活動指引'),
  shopping('消費運勢', '消費決策指引'),
  travel('旅行運勢', '出行建議指引');

  final String name;
  final String description;

  const FortuneType(this.name, this.description);

  /// 獲取運勢類型的顯示名稱
  String get displayName => name;

  /// 獲取運勢類型的詳細描述
  String get detailedDescription => description;

  /// 檢查是否為日常決策類型
  bool get isDaily => 
    this == daily || 
    this == timing || 
    this == activity || 
    this == direction;

  /// 檢查是否為學習職業類型
  bool get isCareer =>
    this == study ||
    this == work ||
    this == programming ||
    this == creative;

  /// 檢查是否為人際互動類型
  bool get isSocial =>
    this == social ||
    this == relationship ||
    this == cooperation;

  /// 檢查是否為生活休閒類型
  bool get isLifestyle =>
    this == health ||
    this == entertainment ||
    this == shopping ||
    this == travel;

  /// 獲取運勢類型的圖標名稱
  String get iconName => switch (this) {
    FortuneType.daily => 'assets/icons/fortune_daily.png',
    FortuneType.timing => 'assets/icons/fortune_timing.png',
    FortuneType.activity => 'assets/icons/fortune_activity.png',
    FortuneType.direction => 'assets/icons/fortune_direction.png',
    FortuneType.study => 'assets/icons/fortune_study.png',
    FortuneType.work => 'assets/icons/fortune_work.png',
    FortuneType.programming => 'assets/icons/fortune_programming.png',
    FortuneType.creative => 'assets/icons/fortune_creative.png',
    FortuneType.social => 'assets/icons/fortune_social.png',
    FortuneType.relationship => 'assets/icons/fortune_relationship.png',
    FortuneType.cooperation => 'assets/icons/fortune_cooperation.png',
    FortuneType.health => 'assets/icons/fortune_health.png',
    FortuneType.entertainment => 'assets/icons/fortune_entertainment.png',
    FortuneType.shopping => 'assets/icons/fortune_shopping.png',
    FortuneType.travel => 'assets/icons/fortune_travel.png'
  };

  /// 獲取運勢類型的分類名稱
  String get categoryName {
    if (isDaily) return '日常決策';
    if (isCareer) return '學習職業';
    if (isSocial) return '人際互動';
    return '生活休閒';
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
      case FortuneType.timing:
      case FortuneType.activity:
      case FortuneType.direction:
        buffer.writeln('• 傳統宜忌');
        buffer.writeln('• 方位五行');
        break;
        
      case FortuneType.study:
      case FortuneType.work:
      case FortuneType.programming:
      case FortuneType.creative:
        buffer.writeln('• 文昌位');
        buffer.writeln('• 事業運勢');
        break;
        
      case FortuneType.social:
      case FortuneType.relationship:
      case FortuneType.cooperation:
        buffer.writeln('• 人緣方位');
        buffer.writeln('• 貴人方位');
        break;
        
      case FortuneType.health:
      case FortuneType.entertainment:
      case FortuneType.shopping:
      case FortuneType.travel:
        buffer.writeln('• 休閒宜忌');
        buffer.writeln('• 財位方向');
        break;
    }
    
    // 添加現代參考（星座）
    buffer.writeln('• 星座參考：當日星象');
    
    return buffer.toString().trim();
  }

  /// 從字符串創建運勢類型
  static FortuneType? fromString(String value) {
    try {
      return FortuneType.values.firstWhere(
        (type) => type.name.toLowerCase() == value.toLowerCase()
      );
    } catch (_) {
      return null;
    }
  }
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
      FortuneType.work.name.toLowerCase(),
      FortuneType.relationship.name.toLowerCase(),
    ].contains(lowerValue);
  }
} 