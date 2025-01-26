import 'package:freezed_annotation/freezed_annotation.dart';

part 'career_fortune.freezed.dart';
part 'career_fortune.g.dart';

/// 事業運勢模型
@freezed
class CareerFortune with _$CareerFortune {
  const factory CareerFortune({
    required int workPerformance,    // 工作表現指數
    required int teamwork,           // 團隊合作指數
    required int leadership,         // 領導力指數
    required int innovation,         // 創新能力指數
    required List<String> opportunities,    // 職業機會
    required List<String> challenges,       // 職業挑戰
    required List<String> careerTips,       // 職業建議
    @Default([]) List<String> investmentTips,  // 投資建議
  }) = _CareerFortune;

  /// 從 JSON 創建
  factory CareerFortune.fromJson(Map<String, dynamic> json) => _$CareerFortuneFromJson(json);
} 