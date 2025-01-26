import 'package:meta/meta.dart';

/// 學業運勢數據模型
@immutable
class StudyFortune {
  /// 唯一標識符
  final String id;
  
  /// 整體運勢評分（0-100）
  final int overallScore;
  
  /// 學習效率指數（0-100）
  final int efficiencyScore;
  
  /// 記憶力指數（0-100）
  final int memoryScore;
  
  /// 考試運勢指數（0-100）
  final int examScore;
  
  /// 最佳學習時段
  final List<String> bestStudyHours;
  
  /// 適合學習的科目
  final List<String> suitableSubjects;
  
  /// 學習建議
  final List<String> studyTips;
  
  /// 吉利方位
  final String? luckyDirection;
  
  /// 運勢描述
  final String description;

  /// 構造函數
  const StudyFortune({
    required this.id,
    required this.overallScore,
    required this.efficiencyScore,
    required this.memoryScore,
    required this.examScore,
    required this.bestStudyHours,
    required this.suitableSubjects,
    required this.studyTips,
    this.luckyDirection,
    required this.description,
  });

  /// 從 JSON 創建實例
  factory StudyFortune.fromJson(Map<String, dynamic> json) {
    return StudyFortune(
      id: json['id'] as String,
      overallScore: json['overallScore'] as int,
      efficiencyScore: json['efficiencyScore'] as int,
      memoryScore: json['memoryScore'] as int,
      examScore: json['examScore'] as int,
      bestStudyHours: List<String>.from(json['bestStudyHours']),
      suitableSubjects: List<String>.from(json['suitableSubjects']),
      studyTips: List<String>.from(json['studyTips']),
      luckyDirection: json['luckyDirection'] as String?,
      description: json['description'] as String,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'overallScore': overallScore,
      'efficiencyScore': efficiencyScore,
      'memoryScore': memoryScore,
      'examScore': examScore,
      'bestStudyHours': bestStudyHours,
      'suitableSubjects': suitableSubjects,
      'studyTips': studyTips,
      'luckyDirection': luckyDirection,
      'description': description,
    };
  }
} 