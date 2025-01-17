import 'package:meta/meta.dart';

/// 事業運勢數據模型
@immutable
class CareerFortune {
  /// 整體運勢評分（0-100）
  final int overallScore;
  
  /// 事業機會指數（0-100）
  final int opportunityScore;
  
  /// 人際關係指數（0-100）
  final int relationshipScore;
  
  /// 財運指數（0-100）
  final int wealthScore;
  
  /// 最佳工作時段
  final List<String> bestWorkingHours;
  
  /// 適合進行的事項
  final List<String> suitableActivities;
  
  /// 需要注意的事項
  final List<String> precautions;
  
  /// 貴人方位
  final String? benefactorDirection;
  
  /// 運勢描述
  final String description;

  /// 構造函數
  const CareerFortune({
    required this.overallScore,
    required this.opportunityScore,
    required this.relationshipScore,
    required this.wealthScore,
    required this.bestWorkingHours,
    required this.suitableActivities,
    required this.precautions,
    this.benefactorDirection,
    required this.description,
  });

  /// 從 JSON 創建實例
  factory CareerFortune.fromJson(Map<String, dynamic> json) {
    return CareerFortune(
      overallScore: json['overallScore'] as int,
      opportunityScore: json['opportunityScore'] as int,
      relationshipScore: json['relationshipScore'] as int,
      wealthScore: json['wealthScore'] as int,
      bestWorkingHours: List<String>.from(json['bestWorkingHours']),
      suitableActivities: List<String>.from(json['suitableActivities']),
      precautions: List<String>.from(json['precautions']),
      benefactorDirection: json['benefactorDirection'] as String?,
      description: json['description'] as String,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'opportunityScore': opportunityScore,
      'relationshipScore': relationshipScore,
      'wealthScore': wealthScore,
      'bestWorkingHours': bestWorkingHours,
      'suitableActivities': suitableActivities,
      'precautions': precautions,
      'benefactorDirection': benefactorDirection,
      'description': description,
    };
  }
} 