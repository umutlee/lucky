import 'package:flutter/foundation.dart';
import 'fortune.dart';

enum SortField {
  date,
  score,
  compatibility,
}

enum SortOrder {
  ascending,
  descending,
}

class FilterCriteria {
  final FortuneType? fortuneType;
  final double? minScore;
  final double? maxScore;
  final bool? isLuckyDay;
  final List<String>? luckyDirections;
  final List<String>? activities;
  final DateTime? startDate;
  final DateTime? endDate;
  final SortField sortField;
  final SortOrder sortOrder;

  const FilterCriteria({
    this.fortuneType,
    this.minScore,
    this.maxScore,
    this.isLuckyDay,
    this.luckyDirections,
    this.activities,
    this.startDate,
    this.endDate,
    this.sortField = SortField.date,
    this.sortOrder = SortOrder.ascending,
  });

  bool get isEmpty =>
      fortuneType == null &&
      minScore == null &&
      maxScore == null &&
      isLuckyDay == null &&
      (luckyDirections == null || luckyDirections!.isEmpty) &&
      (activities == null || activities!.isEmpty) &&
      startDate == null &&
      endDate == null;

  FilterCriteria copyWith({
    FortuneType? fortuneType,
    double? minScore,
    double? maxScore,
    bool? isLuckyDay,
    List<String>? luckyDirections,
    List<String>? activities,
    DateTime? startDate,
    DateTime? endDate,
    SortField? sortField,
    SortOrder? sortOrder,
  }) {
    return FilterCriteria(
      fortuneType: fortuneType ?? this.fortuneType,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      isLuckyDay: isLuckyDay ?? this.isLuckyDay,
      luckyDirections: luckyDirections ?? this.luckyDirections,
      activities: activities ?? this.activities,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterCriteria &&
          runtimeType == other.runtimeType &&
          fortuneType == other.fortuneType &&
          minScore == other.minScore &&
          maxScore == other.maxScore &&
          isLuckyDay == other.isLuckyDay &&
          listEquals(luckyDirections, other.luckyDirections) &&
          listEquals(activities, other.activities) &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          sortField == other.sortField &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      fortuneType.hashCode ^
      minScore.hashCode ^
      maxScore.hashCode ^
      isLuckyDay.hashCode ^
      luckyDirections.hashCode ^
      activities.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      sortField.hashCode ^
      sortOrder.hashCode;

  @override
  String toString() {
    return 'FilterCriteria('
        'fortuneType: $fortuneType, '
        'minScore: $minScore, '
        'maxScore: $maxScore, '
        'isLuckyDay: $isLuckyDay, '
        'luckyDirections: $luckyDirections, '
        'activities: $activities, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'sortField: $sortField, '
        'sortOrder: $sortOrder)';
  }
} 