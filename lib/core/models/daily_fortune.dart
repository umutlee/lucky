import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_fortune.freezed.dart';
part 'daily_fortune.g.dart';

/// 每日運勢模型
@freezed
class DailyFortune with _$DailyFortune {
  const factory DailyFortune({
    required int health,            // 健康指數 (0-100)
    required int wealth,            // 財運指數 (0-100)
    required int social,            // 人際指數 (0-100)
    required int energy,            // 精力指數 (0-100)
    required List<String> goodActivities,    // 宜做事項
    required List<String> badActivities,     // 忌做事項
    required List<String> dailyTips,         // 每日建議
    @Default([]) List<String> healthTips,    // 健康建議
    String? luckyDirection,                  // 吉神方位
    String? wealthDirection,                 // 財神方位
    @Default([]) List<String> luckyHours,    // 吉時
    String? conflictZodiac,                  // 沖煞生肖
    Map<String, int>? horoscope,            // 星座運勢評分
  }) = _DailyFortune;

  /// 從 JSON 創建實例
  factory DailyFortune.fromJson(Map<String, dynamic> json) => 
      _$DailyFortuneFromJson(json);
}