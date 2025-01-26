import 'package:freezed_annotation/freezed_annotation.dart';

part 'love_fortune.freezed.dart';
part 'love_fortune.g.dart';

/// 感情運勢模型
@freezed
class LoveFortune with _$LoveFortune {
  const factory LoveFortune({
    required int attraction,         // 桃花指數
    required int communication,      // 溝通指數
    required int understanding,      // 理解指數
    required int stability,          // 穩定指數
    required List<String> opportunities,    // 戀愛機會
    required List<String> challenges,       // 感情挑戰
    required List<String> relationshipTips, // 感情建議
    @Default([]) List<String> dateTips,     // 約會建議
  }) = _LoveFortune;

  /// 從 JSON 創建
  factory LoveFortune.fromJson(Map<String, dynamic> json) => _$LoveFortuneFromJson(json);
} 