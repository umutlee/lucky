import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune_type.dart';
import 'study_fortune.dart';
import 'career_fortune.dart';
import 'love_fortune.dart';
import 'daily_fortune.dart';

part 'fortune.freezed.dart';
part 'fortune.g.dart';

/// 運勢模型
@freezed
class Fortune with _$Fortune {
  /// 構造函數
  const factory Fortune({
    /// 運勢類型
    required FortuneType type,

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

    /// 詳細運勢（可選）
    StudyFortune? studyFortune,
    CareerFortune? careerFortune,
    LoveFortune? loveFortune,
    DailyFortune? dailyFortune,
  }) = _Fortune;

  /// 從 JSON 創建
  factory Fortune.fromJson(Map<String, dynamic> json) => _$FortuneFromJson(json);

  /// 獲取運勢等級
  static String getFortuneLevel(int score) {
    if (score >= 90) return '大吉';
    if (score >= 80) return '中吉';
    if (score >= 70) return '小吉';
    if (score >= 60) return '平';
    return '凶';
  }

  /// 獲取運勢標籤
  List<String> getTags() {
    final List<String> tags = [];
    
    // 添加運勢等級
    tags.add(getFortuneLevel(score));
    
    // 添加幸運資訊
    if (luckyTimes.isNotEmpty) {
      tags.add('宜在 ${luckyTimes.join("、")} 行事');
    }
    
    if (luckyDirections.isNotEmpty) {
      tags.add('宜往 ${luckyDirections.join("、")} 方向');
    }
    
    if (luckyColors.isNotEmpty) {
      tags.add('宜用 ${luckyColors.join("、")} 色');
    }
    
    if (luckyNumbers.isNotEmpty) {
      tags.add('幸運數字：${luckyNumbers.join("、")}');
    }
    
    return tags;
  }

  /// 獲取詳細運勢描述
  String getDetailedDescription() {
    final StringBuffer buffer = StringBuffer();
    
    // 基本描述
    buffer.writeln(description);
    buffer.writeln();
    
    // 建議
    if (suggestions.isNotEmpty) {
      buffer.writeln('建議：');
      for (final suggestion in suggestions) {
        buffer.writeln('• $suggestion');
      }
      buffer.writeln();
    }
    
    // 注意事項
    if (warnings.isNotEmpty) {
      buffer.writeln('注意事項：');
      for (final warning in warnings) {
        buffer.writeln('• $warning');
      }
      buffer.writeln();
    }
    
    // 特定類型的詳細描述
    switch (type) {
      case FortuneType.study:
        if (studyFortune != null) {
          buffer.writeln('學業運勢詳解：');
          buffer.writeln(studyFortune!.description);
        }
        break;
      case FortuneType.career:
        if (careerFortune != null) {
          buffer.writeln('事業運勢詳解：');
          buffer.writeln(careerFortune!.description);
        }
        break;
      case FortuneType.love:
        if (loveFortune != null) {
          buffer.writeln('愛情運勢詳解：');
          buffer.writeln(loveFortune!.description);
        }
        break;
      default:
        if (dailyFortune != null) {
          buffer.writeln('每日運勢詳解：');
          buffer.writeln(dailyFortune.toString());
        }
    }
    
    return buffer.toString().trim();
  }

  /// 比較運勢
  int compareTo(Fortune other) {
    // 首先比較分數
    final scoreComparison = other.score.compareTo(score);
    if (scoreComparison != 0) return scoreComparison;
    
    // 如果分數相同，比較創建時間（較新的排在前面）
    return other.createdAt.compareTo(createdAt);
  }

  /// 檢查是否為特定類型的運勢
  bool isType(FortuneType checkType) => type == checkType;

  /// 檢查是否為基礎運勢類型
  bool get isBasicType => type.isBasicType;

  /// 檢查是否為特殊運勢類型
  bool get isSpecialType => type.isSpecialType;
}

enum FortuneType {
  daily,    // 每日運勢
  study,    // 學業運勢
  career,   // 事業運勢
  love,     // 感情運勢
} 