import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/compass_direction.dart';
import '../models/filter_criteria.dart';
import 'fortune_direction_service.dart';
import '../utils/logger.dart';

final filterServiceProvider = Provider<FilterService>((ref) {
  return FilterService(ref.read(fortuneDirectionProvider));
});

class FilterService {
  final FortuneDirectionService _fortuneDirectionService;
  final _logger = Logger('FilterService');
  
  // 使用 LRU 緩存存儲過濾結果
  final Map<String, List<Fortune>> _filterCache = {};
  final int _maxCacheSize = 10;

  FilterService(this._fortuneDirectionService);

  List<Fortune> filterFortunes(
    List<Fortune> fortunes,
    FilterCriteria criteria,
    CompassDirection? currentDirection,
  ) {
    if (fortunes.isEmpty) return [];

    var filtered = List<Fortune>.from(fortunes);

    // 根據運勢類型過濾
    if (criteria.fortuneType != null) {
      filtered = filtered.where((f) => f.type == criteria.fortuneType).toList();
    }

    // 根據分數範圍過濾
    if (criteria.minScore != null || criteria.maxScore != null) {
      filtered = filtered.where((f) {
        final score = f.score;
        if (criteria.minScore != null && score < criteria.minScore!) return false;
        if (criteria.maxScore != null && score > criteria.maxScore!) return false;
        return true;
      }).toList();
    }

    // 根據吉日過濾
    if (criteria.isLuckyDay != null) {
      filtered = filtered.where((f) => f.isLuckyDay == criteria.isLuckyDay).toList();
    }

    // 根據推薦活動過濾
    if (criteria.recommendations != null && criteria.recommendations!.isNotEmpty) {
      filtered = filtered.where((f) {
        return f.recommendations.any((activity) => 
          criteria.recommendations!.contains(activity));
      }).toList();
    }

    // 根據日期範圍過濾
    if (criteria.startDate != null || criteria.endDate != null) {
      filtered = filtered.where((f) {
        if (criteria.startDate != null && f.date.isBefore(criteria.startDate!)) {
          return false;
        }
        if (criteria.endDate != null && f.date.isAfter(criteria.endDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    // 根據方位過濾
    if (currentDirection != null && criteria.luckyDirections != null) {
      filtered = filtered.where((f) {
        return criteria.luckyDirections!.contains(currentDirection.toString());
      }).toList();
    }

    // 排序
    filtered.sort((a, b) {
      int comparison;
      switch (criteria.sortField) {
        case SortField.date:
          comparison = a.date.compareTo(b.date);
          break;
        case SortField.score:
          comparison = a.score.compareTo(b.score);
          break;
        case SortField.compatibility:
          comparison = (a.zodiacAffinity[a.zodiac] ?? 0)
              .compareTo(b.zodiacAffinity[b.zodiac] ?? 0);
          break;
      }
      return criteria.sortOrder == SortOrder.ascending
          ? comparison
          : -comparison;
    });

    return filtered;
  }

  List<Fortune> generateRecommendations(List<Fortune> fortunes) {
    if (fortunes.isEmpty) return [];

    // 按分數排序
    final sorted = List<Fortune>.from(fortunes)
      ..sort((a, b) => b.score.compareTo(a.score));

    // 只返回前3個最高分的運勢
    return sorted.take(3).toList();
  }

  // 生成緩存鍵
  String _generateCacheKey(
    List<Fortune> fortunes,
    CompassDirection? currentDirection,
    DateTime currentTime,
    int? minScore,
    List<String>? types,
    bool considerDirection,
    bool considerTime,
  ) {
    return [
      fortunes.map((f) => f.id).join(','),
      currentDirection?.direction ?? 'noDirection',
      '${currentTime.hour}',
      minScore?.toString() ?? 'noScore',
      types?.join(',') ?? 'noTypes',
      considerDirection.toString(),
      considerTime.toString(),
    ].join('|');
  }

  // 更新緩存
  void _updateCache(String key, List<Fortune> value) {
    // 如果緩存已滿，移除最早的項目
    if (_filterCache.length >= _maxCacheSize) {
      final firstKey = _filterCache.keys.first;
      _filterCache.remove(firstKey);
    }
    _filterCache[key] = value;
  }

  // 清除緩存
  void clearCache() {
    _filterCache.clear();
  }
} 