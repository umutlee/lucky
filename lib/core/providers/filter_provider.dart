import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filter_criteria.dart';
import '../models/fortune.dart';
import '../services/filter_service.dart';
import '../utils/logger.dart';
import '../models/fortune_type.dart';

final filterServiceProvider = Provider<FilterService>((ref) => FilterService());

final filterCriteriaProvider =
    StateNotifierProvider<FilterCriteriaNotifier, FilterCriteria>(
  (ref) => FilterCriteriaNotifier(),
);

class FilterCriteriaNotifier extends StateNotifier<FilterCriteria> {
  final _logger = Logger('FilterCriteriaNotifier');

  FilterCriteriaNotifier() : super(const FilterCriteria());

  void updateFortuneType(FortuneType? type) {
    state = state.copyWith(fortuneType: type);
    _logger.info('更新運勢類型: ${type?.name}');
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    _logger.info('更新日期範圍: $start - $end');
  }

  void updateScoreRange(double? min, double? max) {
    state = state.copyWith(minScore: min, maxScore: max);
    _logger.info('更新分數範圍: $min - $max');
  }

  void updateLuckyDay(bool isLuckyDay) {
    state = state.copyWith(isLuckyDay: isLuckyDay);
    _logger.info('更新吉日標記: $isLuckyDay');
  }

  void updateLuckyDirections(List<String> directions) {
    state = state.copyWith(luckyDirections: directions);
    _logger.info('更新吉利方位: $directions');
  }

  void updateActivities(List<String> activities) {
    state = state.copyWith(activities: activities);
    _logger.info('更新適合活動: $activities');
  }

  void updateRecommendations(List<String> recommendations) {
    state = state.copyWith(recommendations: recommendations);
    _logger.info('更新推薦項目: $recommendations');
  }

  void updateSortField(SortField field) {
    state = state.copyWith(sortField: field);
    _logger.info('更新排序欄位: $field');
  }

  void updateSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
    _logger.info('更新排序順序: $order');
  }

  void reset() {
    state = const FilterCriteria();
    _logger.info('重置過濾條件');
  }
}

final filteredFortunesProvider = Provider.family<List<Fortune>, List<Fortune>>((ref, fortunes) {
  final filterService = ref.watch(filterServiceProvider);
  final criteria = ref.watch(filterCriteriaProvider);
  return filterService.filterFortunes(fortunes, criteria);
});

final recommendedFortunesProvider = Provider.family<List<Fortune>, List<Fortune>>((ref, fortunes) {
  final filterService = ref.watch(filterServiceProvider);
  return filterService.generateRecommendations(fortunes);
}); 