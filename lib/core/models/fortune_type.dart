import 'package:meta/meta.dart';

/// 運勢類型
enum FortuneType {
  /// 每日運勢
  daily('每日運勢', '每日運勢分析'),

  /// 學業運勢
  study('學業運勢', '學業運勢分析'),

  /// 事業運勢
  career('事業運勢', '事業運勢分析'),

  /// 愛情運勢
  love('愛情運勢', '愛情運勢分析'),

  /// 財運運勢
  wealth('財運運勢', '財運運勢分析'),

  /// 健康運勢
  health('健康運勢', '健康運勢分析'),

  /// 旅行運勢
  travel('旅行運勢', '旅行運勢分析'),

  /// 社交運勢
  social('社交運勢', '社交運勢分析'),

  /// 創意運勢
  creative('創意運勢', '創意運勢分析');

  const FortuneType(this.displayName, this.description);

  /// 顯示名稱
  final String displayName;

  /// 描述
  final String description;

  /// 從字符串轉換
  static FortuneType fromString(String value) {
    return FortuneType.values.firstWhere(
      (type) => type.name == value || type.displayName == value,
      orElse: () => FortuneType.daily,
    );
  }

  /// 是否為基本運勢類型
  bool get isBasic => this == FortuneType.daily;

  /// 是否為特殊運勢類型
  bool get isSpecial => !isBasic;

  /// 獲取相關運勢類型
  List<FortuneType> get relatedTypes {
    switch (this) {
      case FortuneType.daily:
        return [FortuneType.health, FortuneType.social];
      case FortuneType.study:
        return [FortuneType.career, FortuneType.creative];
      case FortuneType.career:
        return [FortuneType.wealth, FortuneType.social];
      case FortuneType.love:
        return [FortuneType.social, FortuneType.health];
      case FortuneType.wealth:
        return [FortuneType.career, FortuneType.travel];
      case FortuneType.health:
        return [FortuneType.daily, FortuneType.travel];
      case FortuneType.travel:
        return [FortuneType.health, FortuneType.creative];
      case FortuneType.social:
        return [FortuneType.love, FortuneType.career];
      case FortuneType.creative:
        return [FortuneType.study, FortuneType.travel];
    }
  }

  /// 獲取建議時間
  List<String> get suggestedTimes {
    switch (this) {
      case FortuneType.daily:
        return ['早上6點', '晚上9點'];
      case FortuneType.study:
        return ['早上8點', '下午2點'];
      case FortuneType.career:
        return ['早上9點', '下午3點'];
      case FortuneType.love:
        return ['下午4點', '晚上8點'];
      case FortuneType.wealth:
        return ['上午10點', '下午4點'];
      case FortuneType.health:
        return ['早上7點', '晚上10點'];
      case FortuneType.travel:
        return ['上午11點', '下午5點'];
      case FortuneType.social:
        return ['下午1點', '晚上7點'];
      case FortuneType.creative:
        return ['上午10點', '晚上8點'];
    }
  }

  /// 獲取建議方位
  List<String> get suggestedDirections {
    switch (this) {
      case FortuneType.daily:
        return ['東', '南'];
      case FortuneType.study:
        return ['東北', '西南'];
      case FortuneType.career:
        return ['南', '西北'];
      case FortuneType.love:
        return ['西南', '東'];
      case FortuneType.wealth:
        return ['東南', '西'];
      case FortuneType.health:
        return ['北', '南'];
      case FortuneType.travel:
        return ['西', '東南'];
      case FortuneType.social:
        return ['南', '東'];
      case FortuneType.creative:
        return ['東', '西'];
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
      FortuneType.career.name.toLowerCase(),
      FortuneType.love.name.toLowerCase(),
      FortuneType.creative.name.toLowerCase(),
    ].contains(lowerValue);
  }
} 