import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune.dart';

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
    String? type,
    int? minScore,
    int? maxScore,
    bool? isLuckyDay,
    List<String>? activities,
    @Default(SortField.date) SortField sortField,
    @Default(SortOrder.descending) SortOrder sortOrder,
  }) = _FilterCriteria;

  factory FilterCriteria.fromJson(Map<String, dynamic> json) =>
      _$FilterCriteriaFromJson(json);
} 