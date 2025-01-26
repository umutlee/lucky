import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune_type.dart';
import 'study_fortune.dart';
import 'career_fortune.dart';
import 'love_fortune.dart';
import 'daily_fortune.dart';
import 'zodiac.dart';

part 'fortune.freezed.dart';
part 'fortune.g.dart';

/// 運勢模型
@freezed
class Fortune with _$Fortune {
  const Fortune._();  // 添加私有構造函數

  const factory Fortune({
    required String id,
    required String type,
    required String title,
    required int score,
    required String description,
    required DateTime date,
    required List<String> luckyTimes,
    required List<String> luckyDirections,
    required List<String> luckyColors,
    required List<int> luckyNumbers,
    required List<String> suggestions,
    required List<String> warnings,
    required DateTime createdAt,
    @Default(false) bool isLuckyDay,
    @Default([]) List<String> suitableActivities,
    Zodiac? zodiac,
    @Default(0) int zodiacAffinity,
    @Default([]) List<String> recommendations,
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
    if (score >= 50) return '凶';
    return '大凶';
  }

  /// 獲取運勢標籤
  List<String> get tags {
    final tags = <String>[];
    
    tags.add(getFortuneLevel(score));
    
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

  /// 檢查是否為基本運勢類型
  bool get isBasicType => type == 'daily';

  /// 檢查是否為特殊運勢類型
  bool get isSpecialType => ['study', 'career', 'love'].contains(type);
}

enum FortuneType {
  daily,    // 每日運勢
  study,    // 學業運勢
  career,   // 事業運勢
  love,     // 感情運勢
} 