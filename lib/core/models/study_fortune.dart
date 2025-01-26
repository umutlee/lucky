import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_fortune.freezed.dart';
part 'study_fortune.g.dart';

/// 學業運勢模型
@freezed
class StudyFortune with _$StudyFortune {
  const factory StudyFortune({
    required int concentration,     // 專注力指數
    required int comprehension,     // 理解力指數
    required int memory,           // 記憶力指數
    required int creativity,       // 創造力指數
    required List<String> bestSubjects,    // 最佳學習科目
    required List<String> challengingSubjects,  // 需要加強的科目
    required List<String> studyTips,    // 學習建議
    @Default([]) List<String> examTips,  // 考試建議
  }) = _StudyFortune;

  /// 從 JSON 創建
  factory StudyFortune.fromJson(Map<String, dynamic> json) => _$StudyFortuneFromJson(json);
} 