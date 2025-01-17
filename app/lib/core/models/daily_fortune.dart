import 'package:meta/meta.dart';

/// 每日宜忌數據模型
@immutable
class DailyFortune {
  /// 適宜事項列表
  final List<String> goodFor;
  
  /// 不宜事項列表
  final List<String> badFor;
  
  /// 吉神方位
  final String? luckyDirection;
  
  /// 今日財神方位
  final String? wealthDirection;
  
  /// 吉時
  final List<String> luckyHours;
  
  /// 沖煞
  final String? conflictZodiac;
  
  /// 星座運勢（可選）
  final Map<String, int>? horoscope;

  /// 構造函數
  const DailyFortune({
    required this.goodFor,
    required this.badFor,
    this.luckyDirection,
    this.wealthDirection,
    required this.luckyHours,
    this.conflictZodiac,
    this.horoscope,
  });

  /// 從 JSON 創建實例
  factory DailyFortune.fromJson(Map<String, dynamic> json) {
    return DailyFortune(
      goodFor: List<String>.from(json['goodFor']),
      badFor: List<String>.from(json['badFor']),
      luckyDirection: json['luckyDirection'] as String?,
      wealthDirection: json['wealthDirection'] as String?,
      luckyHours: List<String>.from(json['luckyHours']),
      conflictZodiac: json['conflictZodiac'] as String?,
      horoscope: json['horoscope'] != null
          ? Map<String, int>.from(json['horoscope'])
          : null,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'goodFor': goodFor,
      'badFor': badFor,
      'luckyDirection': luckyDirection,
      'wealthDirection': wealthDirection,
      'luckyHours': luckyHours,
      'conflictZodiac': conflictZodiac,
      'horoscope': horoscope,
    };
  }

  @override
  String toString() {
    return '''
宜：${goodFor.join('、')}
忌：${badFor.join('、')}
吉神方位：$luckyDirection
財神方位：$wealthDirection
吉時：${luckyHours.join('、')}
沖煞：$conflictZodiac
''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyFortune &&
        _listEquals(other.goodFor, goodFor) &&
        _listEquals(other.badFor, badFor) &&
        other.luckyDirection == luckyDirection &&
        other.wealthDirection == wealthDirection &&
        _listEquals(other.luckyHours, luckyHours) &&
        other.conflictZodiac == conflictZodiac;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(goodFor),
        Object.hashAll(badFor),
        luckyDirection,
        wealthDirection,
        Object.hashAll(luckyHours),
        conflictZodiac,
      );
}

/// 比較兩個列表是否相等
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
} 