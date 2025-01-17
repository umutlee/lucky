import 'package:meta/meta.dart';

/// 愛情運勢數據模型
@immutable
class LoveFortune {
  /// 整體運勢評分（0-100）
  final int overallScore;
  
  /// 桃花指數（0-100）
  final int romanceScore;
  
  /// 告白成功率（0-100）
  final int confessionScore;
  
  /// 約會運勢（0-100）
  final int dateScore;
  
  /// 最佳約會時段
  final List<String> bestDateHours;
  
  /// 適合的約會活動
  final List<String> suitableDateActivities;
  
  /// 戀愛建議
  final List<String> loveTips;
  
  /// 緣分方位
  final String? destinyDirection;
  
  /// 速配星座
  final List<String> compatibleZodiacs;
  
  /// 運勢描述
  final String description;

  /// 構造函數
  const LoveFortune({
    required this.overallScore,
    required this.romanceScore,
    required this.confessionScore,
    required this.dateScore,
    required this.bestDateHours,
    required this.suitableDateActivities,
    required this.loveTips,
    this.destinyDirection,
    required this.compatibleZodiacs,
    required this.description,
  });

  /// 從 JSON 創建實例
  factory LoveFortune.fromJson(Map<String, dynamic> json) {
    return LoveFortune(
      overallScore: json['overallScore'] as int,
      romanceScore: json['romanceScore'] as int,
      confessionScore: json['confessionScore'] as int,
      dateScore: json['dateScore'] as int,
      bestDateHours: List<String>.from(json['bestDateHours']),
      suitableDateActivities: List<String>.from(json['suitableDateActivities']),
      loveTips: List<String>.from(json['loveTips']),
      destinyDirection: json['destinyDirection'] as String?,
      compatibleZodiacs: List<String>.from(json['compatibleZodiacs']),
      description: json['description'] as String,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'romanceScore': romanceScore,
      'confessionScore': confessionScore,
      'dateScore': dateScore,
      'bestDateHours': bestDateHours,
      'suitableDateActivities': suitableDateActivities,
      'loveTips': loveTips,
      'destinyDirection': destinyDirection,
      'compatibleZodiacs': compatibleZodiacs,
      'description': description,
    };
  }

  /// 獲取桃花等級描述
  String get romanceLevel {
    if (romanceScore >= 90) return '超級旺桃花';
    if (romanceScore >= 80) return '桃花旺盛';
    if (romanceScore >= 70) return '桃花不錯';
    if (romanceScore >= 60) return '桃花平平';
    return '桃花較弱';
  }

  /// 獲取告白建議時機
  String get confessionAdvice {
    if (confessionScore >= 90) return '絕佳告白時機！';
    if (confessionScore >= 80) return '適合表達心意';
    if (confessionScore >= 70) return '時機尚可';
    if (confessionScore >= 60) return '建議再等等';
    return '不適合告白';
  }
} 