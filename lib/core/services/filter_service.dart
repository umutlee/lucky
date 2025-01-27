import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/compass_direction.dart';
import '../models/filter_criteria.dart';
import '../models/fortune_type.dart';
import '../utils/logger.dart';

final filterServiceProvider = Provider<FilterService>((ref) => FilterService());

class FilterService {
  final _logger = Logger('FilterService');
  
  // 使用 LRU 緩存存儲過濾結果
  final Map<String, List<Fortune>> _filterCache = {};
  final int _maxCacheSize = 10;

  FilterService();

  List<Fortune> filterFortunes(List<Fortune> fortunes, FilterCriteria criteria) {
    try {
      // 生成緩存鍵
      final cacheKey = _generateCacheKey(fortunes, criteria);
      
      // 檢查緩存
      if (_filterCache.containsKey(cacheKey)) {
        _logger.info('使用緩存的過濾結果');
        return List<Fortune>.from(_filterCache[cacheKey]!);
      }

      var filtered = List<Fortune>.from(fortunes);

      // 按類型過濾
      if (criteria.fortuneType != null) {
        filtered = filtered.where((f) => f.type == criteria.fortuneType).toList();
      }

      // 按分數範圍過濾
      if (criteria.minScore != null) {
        filtered = filtered.where((f) => f.score >= criteria.minScore!).toList();
      }
      if (criteria.maxScore != null) {
        filtered = filtered.where((f) => f.score <= criteria.maxScore!).toList();
      }

      // 按吉日過濾
      if (criteria.isLuckyDay != null) {
        filtered = filtered.where((f) => f.isLuckyDay == criteria.isLuckyDay).toList();
      }

      // 按日期範圍過濾
      if (criteria.startDate != null) {
        filtered = filtered.where((f) => 
          f.date.isAfter(criteria.startDate!) || 
          f.date.isAtSameMomentAs(criteria.startDate!)
        ).toList();
      }
      if (criteria.endDate != null) {
        filtered = filtered.where((f) => 
          f.date.isBefore(criteria.endDate!) || 
          f.date.isAtSameMomentAs(criteria.endDate!)
        ).toList();
      }

      // 按方位過濾
      if (criteria.luckyDirections != null && criteria.luckyDirections!.isNotEmpty) {
        filtered = filtered.where((f) => 
          f.luckyDirections.any((d) => criteria.luckyDirections!.contains(d))
        ).toList();
      }

      // 按活動過濾
      if (criteria.activities != null && criteria.activities!.isNotEmpty) {
        filtered = filtered.where((f) => 
          f.suitableActivities.any((a) => criteria.activities!.contains(a))
        ).toList();
      }

      // 按推薦過濾
      if (criteria.recommendations != null && criteria.recommendations!.isNotEmpty) {
        filtered = filtered.where((f) => 
          f.recommendations.any((r) => criteria.recommendations!.contains(r))
        ).toList();
      }

      // 排序結果
      filtered.sort((a, b) {
        final result = switch (criteria.sortField) {
          SortField.date => a.date.compareTo(b.date),
          SortField.score => a.score.compareTo(b.score),
          SortField.type => a.type.name.compareTo(b.type.name),
        };
        return criteria.sortOrder == SortOrder.ascending ? result : -result;
      });

      // 更新緩存
      _updateCache(cacheKey, filtered);

      return filtered;
    } catch (e, stackTrace) {
      _logger.error('過濾運勢失敗', e, stackTrace);
      return [];
    }
  }

  List<Fortune> generateRecommendations(List<Fortune> fortunes) {
    if (fortunes.isEmpty) return [];

    try {
      // 按分數排序
      final sorted = List<Fortune>.from(fortunes)
        ..sort((a, b) => b.score.compareTo(a.score));

      // 只返回前3個最高分的運勢
      return sorted.take(3).toList();
    } catch (e, stackTrace) {
      _logger.error('生成推薦失敗', e, stackTrace);
      return [];
    }
  }

  // 生成緩存鍵
  String _generateCacheKey(List<Fortune> fortunes, FilterCriteria criteria) {
    return [
      fortunes.map((f) => f.id).join(','),
      criteria.fortuneType?.name ?? 'noType',
      criteria.minScore?.toString() ?? 'noMinScore',
      criteria.maxScore?.toString() ?? 'noMaxScore',
      criteria.isLuckyDay?.toString() ?? 'noLuckyDay',
      criteria.startDate?.toIso8601String() ?? 'noStartDate',
      criteria.endDate?.toIso8601String() ?? 'noEndDate',
      criteria.luckyDirections?.join(',') ?? 'noDirections',
      criteria.activities?.join(',') ?? 'noActivities',
      criteria.recommendations?.join(',') ?? 'noRecommendations',
      criteria.sortField.toString(),
      criteria.sortOrder.toString(),
    ].join('|');
  }

  // 更新緩存
  void _updateCache(String key, List<Fortune> value) {
    // 如果緩存已滿，移除最早的項目
    if (_filterCache.length >= _maxCacheSize) {
      final firstKey = _filterCache.keys.first;
      _filterCache.remove(firstKey);
    }
    _filterCache[key] = List<Fortune>.from(value);
  }

  // 清除緩存
  void clearCache() {
    _filterCache.clear();
    _logger.info('緩存已清除');
  }
} 