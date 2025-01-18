import 'package:flutter/foundation.dart';
import '../models/filter_criteria.dart';
import '../models/fortune.dart';
import '../utils/logger.dart';

class FilterService {
  final Logger _logger = Logger('FilterService');

  /// 根據篩選條件過濾運勢數據
  List<Fortune> filterFortunes(List<Fortune> fortunes, FilterCriteria criteria) {
    if (criteria.isEmpty) {
      return fortunes;
    }

    try {
      return fortunes.where((fortune) {
        // 檢查運勢類型
        if (criteria.fortuneType != null && 
            fortune.type != criteria.fortuneType) {
          return false;
        }

        // 檢查分數範圍
        if (criteria.minScore != null && 
            fortune.score < criteria.minScore!) {
          return false;
        }
        if (criteria.maxScore != null && 
            fortune.score > criteria.maxScore!) {
          return false;
        }

        // 檢查吉日
        if (criteria.isLuckyDay != null && 
            fortune.isLuckyDay != criteria.isLuckyDay) {
          return false;
        }

        // 檢查方位
        if (criteria.luckyDirections != null && 
            criteria.luckyDirections!.isNotEmpty) {
          bool hasMatchingDirection = criteria.luckyDirections!
              .any((direction) => fortune.luckyDirections.contains(direction));
          if (!hasMatchingDirection) {
            return false;
          }
        }

        // 檢查活動
        if (criteria.activities != null && 
            criteria.activities!.isNotEmpty) {
          bool hasMatchingActivity = criteria.activities!
              .any((activity) => fortune.suitableActivities.contains(activity));
          if (!hasMatchingActivity) {
            return false;
          }
        }

        // 檢查日期範圍
        if (criteria.startDate != null && 
            fortune.date.isBefore(criteria.startDate!)) {
          return false;
        }
        if (criteria.endDate != null && 
            fortune.date.isAfter(criteria.endDate!)) {
          return false;
        }

        return true;
      }).toList();
    } catch (e) {
      _logger.error('過濾運勢數據時發生錯誤: $e');
      return [];
    }
  }

  /// 根據排序條件對結果進行排序
  List<Fortune> sortFortunes(List<Fortune> fortunes, FilterCriteria criteria) {
    try {
      List<Fortune> sortedFortunes = List.from(fortunes);
      
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
            comparison = a.compatibility.compareTo(b.compatibility);
            break;
          default:
            comparison = 0;
        }

        return criteria.sortOrder == SortOrder.ascending
            ? comparison
            : -comparison;
      });

      return sortedFortunes;
    } catch (e) {
      _logger.error('排序運勢數據時發生錯誤: $e');
      return fortunes;
    }
  }

  /// 根據用戶歷史數據生成推薦
  List<Fortune> generateRecommendations(
    List<Fortune> fortunes,
    List<Fortune> userHistory,
  ) {
    try {
      // 分析用戶偏好
      Map<FortuneType, int> typePreferences = {};
      Map<String, int> activityPreferences = {};
      Map<String, int> directionPreferences = {};

      for (var fortune in userHistory) {
        // 統計運勢類型偏好
        typePreferences[fortune.type] = 
            (typePreferences[fortune.type] ?? 0) + 1;

        // 統計活動偏好
        for (var activity in fortune.suitableActivities) {
          activityPreferences[activity] = 
              (activityPreferences[activity] ?? 0) + 1;
        }

        // 統計方位偏好
        for (var direction in fortune.luckyDirections) {
          directionPreferences[direction] = 
              (directionPreferences[direction] ?? 0) + 1;
        }
      }

      // 為每個運勢計算推薦分數
      return fortunes.map((fortune) {
        int recommendationScore = 0;

        // 根據運勢類型加分
        recommendationScore += typePreferences[fortune.type] ?? 0;

        // 根據活動匹配度加分
        for (var activity in fortune.suitableActivities) {
          recommendationScore += activityPreferences[activity] ?? 0;
        }

        // 根據方位匹配度加分
        for (var direction in fortune.luckyDirections) {
          recommendationScore += directionPreferences[direction] ?? 0;
        }

        // 將推薦分數添加到運勢對象中
        return fortune.copyWith(
          recommendationScore: recommendationScore,
        );
      }).toList()
        ..sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
    } catch (e) {
      _logger.error('生成推薦時發生錯誤: $e');
      return fortunes;
    }
  }
} 