import 'package:meta/meta.dart';
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
    required FortuneType type,
    required String title,
    required int score,
    required String description,
    required DateTime date,
    required DateTime createdAt,
    required List<String> luckyTimes,
    required List<String> luckyDirections,
    required List<String> luckyColors,
    required List<int> luckyNumbers,
    required List<String> suggestions,
    required List<String> warnings,
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
  String get level {
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
    
    tags.add(level);
    
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
  String get detailedDescription {
    final buffer = StringBuffer();
    
    buffer.writeln('【運勢指數】${score}分 - $level');
    
    if (luckyColors.isNotEmpty) {
      buffer.writeln('【幸運顏色】${luckyColors.join('、')}');
    }
    
    if (luckyNumbers.isNotEmpty) {
      buffer.writeln('【幸運數字】${luckyNumbers.join('、')}');
    }
    
    if (zodiac != null) {
      buffer.writeln('【生肖相性】${zodiac!.name} - ${_getAffinityLevel(zodiacAffinity)}');
    }
    
    if (recommendations.isNotEmpty) {
      buffer.writeln('\n【運勢建議】');
      for (final recommendation in recommendations) {
        buffer.writeln('• $recommendation');
      }
    }
    
    return buffer.toString();
  }

  String _getAffinityLevel(int affinity) {
    if (affinity >= 90) return '極高';
    if (affinity >= 80) return '很高';
    if (affinity >= 70) return '較高';
    if (affinity >= 60) return '一般';
    if (affinity >= 50) return '較低';
    return '很低';
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
  bool get isBasicType => type == FortuneType.daily;

  /// 檢查是否為特殊運勢類型
  bool get isSpecialType => [FortuneType.study, FortuneType.career, FortuneType.love].contains(type);
} 