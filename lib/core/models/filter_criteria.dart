import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune.dart';

part 'filter_criteria.freezed.dart';
part 'filter_criteria.g.dart';

enum SortField {
  date,
  score,
  compatibility,
}

enum SortOrder {
  ascending,
  descending,
}

@freezed
class FilterCriteria with _$FilterCriteria {
  const factory FilterCriteria({
    FortuneType? fortuneType,
    double? minScore,
    double? maxScore,
    bool? isLuckyDay,
    List<String>? luckyDirections,
    List<String>? recommendations,
    DateTime? startDate,
    DateTime? endDate,
    @Default(SortField.date) SortField sortField,
    @Default(SortOrder.ascending) SortOrder sortOrder,
  }) = _FilterCriteria;

  factory FilterCriteria.fromJson(Map<String, dynamic> json) =>
      _$FilterCriteriaFromJson(json);
} 