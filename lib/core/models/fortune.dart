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
  const factory Fortune({
    required String id,
    required String title,
    required String description,
    required int overallScore,
    required DateTime date,
    required Map<String, int> scores,
    required List<String> advice,
    required List<String> luckyColors,
    required List<String> luckyNumbers,
    required List<String> luckyDirections,
    required FortuneType type,
    Zodiac? zodiac,
    String? constellation,
    @Default([]) List<String> warnings,
    @Default([]) List<String> opportunities,
    @Default({}) Map<String, dynamic> additionalData,
    @Default(0) int score,
    StudyFortune? studyFortune,
    CareerFortune? careerFortune,
    LoveFortune? loveFortune,
    DailyFortune? dailyFortune,
  }) = _Fortune;

  /// 從 JSON 創建
  factory Fortune.fromJson(Map<String, dynamic> json) => _$FortuneFromJson(json);

  const Fortune._();  // 添加私有構造函數

  bool get isLucky => overallScore >= 80;
  bool get isUnlucky => overallScore <= 20;
  bool get isNeutral => !isLucky && !isUnlucky;

  String get luckLevel {
    if (isLucky) return '大吉';
    if (isUnlucky) return '凶';
    if (overallScore >= 60) return '小吉';
    if (overallScore >= 40) return '平';
    return '小凶';
  }

  String get summary {
    if (isLucky) {
      return '今日運勢非常好，適合大展拳腳！';
    } else if (isUnlucky) {
      return '今日運勢欠佳，宜小心謹慎。';
    } else if (overallScore >= 60) {
      return '今日運勢不錯，可以嘗試新事物。';
    } else if (overallScore >= 40) {
      return '今日運勢平平，按部就班即可。';
    } else {
      return '今日運勢稍差，建議多加小心。';
    }
  }

  List<String> get keyPoints {
    final points = <String>[];
    
    if (scores.containsKey('love') && scores['love']! >= 80) {
      points.add('桃花運旺盛');
    }
    
    if (scores.containsKey('wealth') && scores['wealth']! >= 80) {
      points.add('財運亨通');
    }
    
    if (scores.containsKey('career') && scores['career']! >= 80) {
      points.add('事業有成');
    }
    
    if (warnings.isNotEmpty) {
      points.add('需要注意: ${warnings.first}');
    }
    
    if (opportunities.isNotEmpty) {
      points.add('機會: ${opportunities.first}');
    }
    
    return points;
  }

  /// 獲取運勢等級
  String get level {
    if (overallScore >= 90) return '大吉';
    if (overallScore >= 80) return '中吉';
    if (overallScore >= 70) return '小吉';
    if (overallScore >= 60) return '平';
    if (overallScore >= 50) return '凶';
    return '大凶';
  }

  /// 獲取運勢標籤
  List<String> get tags {
    final tags = <String>[];
    
    tags.add(level);
    
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
    
    buffer.writeln('【運勢指數】${overallScore}分 - $level');
    
    if (luckyColors.isNotEmpty) {
      buffer.writeln('【幸運顏色】${luckyColors.join('、')}');
    }
    
    if (luckyNumbers.isNotEmpty) {
      buffer.writeln('【幸運數字】${luckyNumbers.join('、')}');
    }
    
    if (zodiac != null) {
      buffer.writeln('【生肖相性】${zodiac!.displayName}');
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('\n【運勢建議】');
      for (final warning in warnings) {
        buffer.writeln('• $warning');
      }
    }
    
    return buffer.toString();
  }

  /// 比較運勢
  int compareTo(Fortune other) {
    // 首先比較分數
    final scoreComparison = other.overallScore.compareTo(overallScore);
    if (scoreComparison != 0) return scoreComparison;
    
    // 如果分數相同，比較創建時間（較新的排在前面）
    return other.date.compareTo(date);
  }

  /// 檢查是否為特定類型的運勢
  bool isType(FortuneType checkType) => type == checkType;

  /// 檢查是否為基本運勢類型
  bool get isBasicType => type == FortuneType.daily;

  /// 檢查是否為特殊運勢類型
  bool get isSpecialType => [FortuneType.study, FortuneType.career, FortuneType.love].contains(type);
} 