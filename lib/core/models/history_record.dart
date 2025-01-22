import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_record.freezed.dart';
part 'history_record.g.dart';

@freezed
class HistoryRecord with _$HistoryRecord {
  const factory HistoryRecord({
    required String id,
    required DateTime timestamp,
    required String fortuneType,    // 運勢類型
    required String fortuneResult,  // 運勢結果
    String? notes,                  // 用戶備註
    @Default(false) bool isFavorite, // 是否收藏
  }) = _HistoryRecord;

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => 
      _$HistoryRecordFromJson(json);
} 