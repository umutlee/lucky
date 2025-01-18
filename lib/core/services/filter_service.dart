import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/compass_direction.dart';
import 'fortune_direction_service.dart';
import '../utils/logger.dart';

final filterServiceProvider = Provider<FilterService>((ref) {
  final fortuneDirectionService = ref.watch(fortuneDirectionProvider);
  return FilterService(fortuneDirectionService);
});

class FilterService {
  final FortuneDirectionService _fortuneDirectionService;
  final _logger = Logger('FilterService');
  
  // 使用 LRU 緩存存儲過濾結果
  final Map<String, List<Fortune>> _filterCache = {};
  final int _maxCacheSize = 10;

  FilterService(this._fortuneDirectionService);

  // 根據條件過濾運勢
  List<Fortune> filterFortunes(
    List<Fortune> fortunes,
    CompassDirection? currentDirection,
    DateTime currentTime, {
    int? minScore,
    List<String>? types,
    bool considerDirection = true,
    bool considerTime = true,
  }) {
    try {
      // 生成緩存鍵
      final cacheKey = _generateCacheKey(
        fortunes,
        currentDirection,
        currentTime,
        minScore,
        types,
        considerDirection,
        considerTime,
      );

      // 檢查緩存
      if (_filterCache.containsKey(cacheKey)) {
        _logger.info('使用緩存的過濾結果');
        return _filterCache[cacheKey]!;
      }

      // 應用過濾條件
      final filtered = fortunes.where((fortune) {
        // 檢查分數
        if (minScore != null && fortune.score < minScore) {
          return false;
        }

        // 檢查類型
        if (types != null && types.isNotEmpty && !types.contains(fortune.type)) {
          return false;
        }

        // 檢查方位
        if (considerDirection && currentDirection != null) {
          final luckyDirections = _fortuneDirectionService.getLuckyDirections(fortune);
          if (!luckyDirections.contains(currentDirection.direction)) {
            return false;
          }
        }

        // 檢查時間
        if (considerTime) {
          if (!_fortuneDirectionService.isGoodTimeForActivity(fortune, currentTime)) {
            return false;
          }
        }

        return true;
      }).toList();

      // 根據分數和時間排序
      filtered.sort((a, b) {
        // 首先按分數排序
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;

        // 分數相同時，考慮時間適合度
        if (considerTime) {
          final aTimeGood = _fortuneDirectionService.isGoodTimeForActivity(a, currentTime);
          final bTimeGood = _fortuneDirectionService.isGoodTimeForActivity(b, currentTime);
          if (aTimeGood != bTimeGood) {
            return bTimeGood ? 1 : -1;
          }
        }

        // 最後按 ID 排序確保穩定性
        return a.id.compareTo(b.id);
      });

      // 更新緩存
      _updateCache(cacheKey, filtered);

      return filtered;
    } catch (e) {
      _logger.error('過濾運勢時發生錯誤: $e');
      return [];
    }
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