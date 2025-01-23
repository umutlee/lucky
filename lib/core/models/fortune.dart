import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fortune.freezed.dart';
part 'fortune.g.dart';

/// 運勢模型
@freezed
class Fortune with _$Fortune {
  /// 構造函數
  const factory Fortune({
    /// 運勢類型
    required String type,

    /// 運勢分數
    required int score,

    /// 運勢描述
    required String description,

    /// 幸運時段
    required List<String> luckyTimes,

    /// 幸運方位
    required List<String> luckyDirections,

    /// 幸運顏色
    required List<String> luckyColors,

    /// 幸運數字
    required List<int> luckyNumbers,

    /// 建議
    required List<String> suggestions,

    /// 注意事項
    required List<String> warnings,

    /// 創建時間
    required DateTime createdAt,
  }) = _Fortune;

  /// 從 JSON 創建
  factory Fortune.fromJson(Map<String, dynamic> json) => _$FortuneFromJson(json);
}

enum FortuneType {
  daily,    // 每日運勢
  study,    // 學業運勢
  career,   // 事業運勢
  love,     // 感情運勢
} 