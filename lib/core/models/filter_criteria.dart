import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune_type.dart';

part 'filter_criteria.freezed.dart';
part 'filter_criteria.g.dart';

enum SortField {
  date,
  score,
  type
}

enum SortOrder {
  ascending,
  descending
}

@freezed
class FilterCriteria with _$FilterCriteria {
  const factory FilterCriteria({
    DateTime? startDate,
    DateTime? endDate,
    FortuneType? fortuneType,
    double? minScore,
    double? maxScore,
    @Default(false) bool isLuckyDay,
    @Default([]) List<String> luckyDirections,
    @Default([]) List<String> activities,
    List<String>? recommendations,
    @Default(SortField.date) SortField sortField,
    @Default(SortOrder.descending) SortOrder sortOrder,
  }) = _FilterCriteria;

  factory FilterCriteria.fromJson(Map<String, dynamic> json) =>
      _$FilterCriteriaFromJson(json);

  const FilterCriteria._();

  bool get hasAnyFilter =>
      startDate != null ||
      endDate != null ||
      fortuneType != null ||
      minScore != null ||
      maxScore != null ||
      isLuckyDay == true ||
      (luckyDirections?.isNotEmpty ?? false) ||
      (activities?.isNotEmpty ?? false) ||
      (recommendations?.isNotEmpty ?? false);
} 