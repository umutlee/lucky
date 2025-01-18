import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filter_criteria.dart';
import '../models/fortune.dart';
import '../services/filter_service.dart';
import '../utils/logger.dart';

final filterServiceProvider = Provider<FilterService>((ref) => FilterService());

final filterCriteriaProvider = StateNotifierProvider<FilterCriteriaNotifier, FilterCriteria>((ref) {
  return FilterCriteriaNotifier();
});

class FilterCriteriaNotifier extends StateNotifier<FilterCriteria> {
  final Logger _logger = Logger('FilterCriteriaNotifier');

  FilterCriteriaNotifier() : super(const FilterCriteria());

  void updateFortuneType(FortuneType? type) {
    state = state.copyWith(fortuneType: type);
    _logger.info('更新運勢類型: $type');
  }

  void updateScoreRange(double? min, double? max) {
    if (min != null && max != null && min > max) {
      _logger.warning('分數範圍無效: min($min) > max($max)');
      return;
    }
    state = state.copyWith(minScore: min, maxScore: max);
    _logger.info('更新分數範圍: $min - $max');
  }

  void updateLuckyDay(bool? isLucky) {
    state = state.copyWith(isLuckyDay: isLucky);
    _logger.info('更新吉日標記: $isLucky');
  }

  void updateLuckyDirections(List<String>? directions) {
    state = state.copyWith(luckyDirections: directions);
    _logger.info('更新吉利方位: $directions');
  }

  void updateActivities(List<String>? activities) {
    state = state.copyWith(activities: activities);
    _logger.info('更新活動列表: $activities');
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null && start.isAfter(end)) {
      _logger.warning('日期範圍無效: start($start) > end($end)');
      return;
    }
    state = state.copyWith(startDate: start, endDate: end);
    _logger.info('更新日期範圍: $start - $end');
  }

  void updateSortField(SortField field) {
    state = state.copyWith(sortField: field);
    _logger.info('更新排序欄位: $field');
  }

  void updateSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
    _logger.info('更新排序方式: $order');
  }

  void reset() {
    state = const FilterCriteria();
    _logger.info('重置篩選條件');
  }
}

final filteredFortunesProvider = Provider.family<List<Fortune>, List<Fortune>>((ref, fortunes) {
  final filterService = ref.watch(filterServiceProvider);
  final criteria = ref.watch(filterCriteriaProvider);
  
  // 先過濾
  final filtered = filterService.filterFortunes(fortunes, criteria);
  // 再排序
  return filterService.sortFortunes(filtered, criteria);
});

final recommendedFortunesProvider = Provider.family<List<Fortune>, List<Fortune>>((ref, fortunes) {
  final filterService = ref.watch(filterServiceProvider);
  final userHistory = []; // TODO: 從用戶歷史記錄中獲取
  
  return filterService.generateRecommendations(fortunes, userHistory);
}); 