import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_record.freezed.dart';
part 'history_record.g.dart';

@freezed
class HistoryRecord with _$HistoryRecord {
  const factory HistoryRecord({
    required String id,
    required DateTime timestamp,
    required String fortuneType,
    required String fortuneResult,
    String? notes,
    @Default(false) bool isFavorite,
  }) = _HistoryRecord;

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => 
      _$HistoryRecordFromJson(json);
} 