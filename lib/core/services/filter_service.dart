import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/utils/logger.dart';

class FilterService {
  final _logger = Logger('FilterService');
  final Map<String, List<Fortune>> _recommendationsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = Duration(minutes: 30);

  List<Fortune> generateRecommendations(List<Fortune> fortunes, {List<Fortune>? userHistory}) {
    final cacheKey = _generateCacheKey(fortunes, userHistory);
    
    if (_isValidCache(cacheKey)) {
      _logger.info('返回緩存的推薦結果');
      return List<Fortune>.from(_recommendationsCache[cacheKey]!);
    }

    _cleanupOldCache();
    
    List<Fortune> recommendations;
    if (userHistory == null || userHistory.isEmpty) {
      recommendations = List<Fortune>.from(fortunes)
        ..sort((a, b) => b.score.compareTo(a.score));
    } else {
      final preferences = _analyzeUserPreferences(userHistory);
      recommendations = _generateRecommendationsWithPreferences(fortunes, preferences);
    }

    _cacheRecommendations(cacheKey, recommendations);
    _logger.info('生成了 ${recommendations.length} 條推薦');
    return recommendations;
  }

  UserPreferences _analyzeUserPreferences(List<Fortune> history) {
    final typePreferences = <FortuneType, int>{};
    final activityPreferences = <String, int>{};
    final directionPreferences = <String, int>{};

    for (var fortune in history) {
      typePreferences[fortune.type] = (typePreferences[fortune.type] ?? 0) + 1;
      for (var activity in fortune.suitableActivities) {
        activityPreferences[activity] = (activityPreferences[activity] ?? 0) + 1;
      }
      for (var direction in fortune.luckyDirections) {
        directionPreferences[direction] = (directionPreferences[direction] ?? 0) + 1;
      }
    }

    return UserPreferences(
      typePreferences: typePreferences,
      activityPreferences: activityPreferences,
      directionPreferences: directionPreferences
    );
  }

  List<Fortune> _generateRecommendationsWithPreferences(
    List<Fortune> fortunes,
    UserPreferences preferences
  ) {
    final scoredFortunes = fortunes.map((fortune) {
      var score = fortune.score * 0.4; // 基礎分數權重 40%
      
      // 類型匹配 (20%)
      final typeScore = preferences.typePreferences[fortune.type] ?? 0;
      score += (typeScore / preferences.typePreferences.length) * 20;
      
      // 活動匹配 (20%)
      var activityScore = 0.0;
      for (var activity in fortune.suitableActivities) {
        activityScore += preferences.activityPreferences[activity] ?? 0;
      }
      score += (activityScore / preferences.activityPreferences.length) * 20;
      
      // 方向匹配 (10%)
      var directionScore = 0.0;
      for (var direction in fortune.luckyDirections) {
        directionScore += preferences.directionPreferences[direction] ?? 0;
      }
      score += (directionScore / preferences.directionPreferences.length) * 10;
      
      // 時間因素 (10%)
      final daysDifference = fortune.date.difference(DateTime.now()).inDays.abs();
      score += (1 - (daysDifference / 30)) * 10; // 假設30天為最大時間跨度
      
      return MapEntry(fortune, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return scoredFortunes.map((entry) => entry.key).toList();
  }

  String _generateCacheKey(List<Fortune> fortunes, List<Fortune>? userHistory) {
    final fortunesKey = fortunes.map((f) => '${f.type}-${f.score}-${f.date}').join('_');
    final historyKey = userHistory?.map((f) => '${f.type}-${f.score}-${f.date}').join('_') ?? 'no_history';
    return '$fortunesKey|$historyKey';
  }

  bool _isValidCache(String key) {
    if (!_recommendationsCache.containsKey(key)) return false;
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <= _cacheDuration;
  }

  void _cacheRecommendations(String key, List<Fortune> recommendations) {
    _recommendationsCache[key] = List<Fortune>.from(recommendations);
    _cacheTimestamps[key] = DateTime.now();
  }

  void _cleanupOldCache() {
    final now = DateTime.now();
    _cacheTimestamps.removeWhere((key, timestamp) {
      final isExpired = now.difference(timestamp) > _cacheDuration;
      if (isExpired) {
        _recommendationsCache.remove(key);
      }
      return isExpired;
    });
  }

  List<Fortune> filterFortunes(List<Fortune> fortunes, FilterCriteria criteria) {
    if (criteria.isEmpty) return List<Fortune>.from(fortunes);
    
    return fortunes.where((fortune) {
      // 運勢類型篩選
      if (criteria.fortuneType != null && fortune.type != criteria.fortuneType) {
        return false;
      }
      
      // 分數範圍篩選
      if (criteria.minScore != null && fortune.score < criteria.minScore!) {
        return false;
      }
      if (criteria.maxScore != null && fortune.score > criteria.maxScore!) {
        return false;
      }
      
      // 吉日篩選
      if (criteria.isLuckyDay != null && fortune.isLuckyDay != criteria.isLuckyDay) {
        return false;
      }
      
      // 方位篩選
      if (criteria.luckyDirections != null && criteria.luckyDirections!.isNotEmpty) {
        if (!fortune.luckyDirections.any((d) => criteria.luckyDirections!.contains(d))) {
          return false;
        }
      }
      
      // 活動篩選
      if (criteria.activities != null && criteria.activities!.isNotEmpty) {
        if (!fortune.suitableActivities.any((a) => criteria.activities!.contains(a))) {
          return false;
        }
      }
      
      // 日期範圍篩選
      if (criteria.startDate != null && fortune.date.isBefore(criteria.startDate!)) {
        return false;
      }
      if (criteria.endDate != null && fortune.date.isAfter(criteria.endDate!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<Fortune> sortFortunes(List<Fortune> fortunes, FilterCriteria criteria) {
    final sortedFortunes = List<Fortune>.from(fortunes);
    
    sortedFortunes.sort((a, b) {
      int comparison;
      
      switch (criteria.sortField) {
        case SortField.date:
          comparison = a.date.compareTo(b.date);
          break;
        case SortField.score:
          comparison = a.score.compareTo(b.score);
          break;
        case SortField.compatibility:
          // 根據活動和方位的匹配度計算相容性分數
          final aScore = _calculateCompatibilityScore(a, criteria);
          final bScore = _calculateCompatibilityScore(b, criteria);
          comparison = aScore.compareTo(bScore);
          break;
      }
      
      return criteria.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    return sortedFortunes;
  }

  double _calculateCompatibilityScore(Fortune fortune, FilterCriteria criteria) {
    double score = fortune.score;
    
    // 方位匹配度 (權重：30%)
    if (criteria.luckyDirections != null && criteria.luckyDirections!.isNotEmpty) {
      final matchingDirections = fortune.luckyDirections
          .where((d) => criteria.luckyDirections!.contains(d))
          .length;
      score += (matchingDirections / criteria.luckyDirections!.length) * 30;
    }
    
    // 活動匹配度 (權重：30%)
    if (criteria.activities != null && criteria.activities!.isNotEmpty) {
      final matchingActivities = fortune.suitableActivities
          .where((a) => criteria.activities!.contains(a))
          .length;
      score += (matchingActivities / criteria.activities!.length) * 30;
    }
    
    return score;
  }
}

class UserPreferences {
  final Map<FortuneType, int> typePreferences;
  final Map<String, int> activityPreferences;
  final Map<String, int> directionPreferences;

  UserPreferences({
    required this.typePreferences,
    required this.activityPreferences,
    required this.directionPreferences,
  });
} 