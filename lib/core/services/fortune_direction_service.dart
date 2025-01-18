import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/compass_direction.dart';
import 'compass_service.dart';

final fortuneDirectionProvider = Provider<FortuneDirectionService>((ref) {
  return FortuneDirectionService();
});

class FortuneDirectionService {
  final _compassService = CompassService();

  // 根據運勢獲取吉利方位
  List<String> getLuckyDirections(Fortune fortune) {
    final directions = <String>[];
    
    // 根據運勢分數決定吉利方位數量
    final score = fortune.score;
    if (score >= 90) {
      // 極好運勢：四個方位都吉利
      directions.addAll(['東', '南', '西', '北']);
    } else if (score >= 80) {
      // 好運勢：三個方位吉利
      directions.addAll(['東', '南', '北']);
    } else if (score >= 70) {
      // 中等運勢：兩個方位吉利
      directions.addAll(['東', '南']);
    } else if (score >= 60) {
      // 一般運勢：一個方位吉利
      directions.add('東');
    } else {
      // 運勢欠佳：建議避開的方位
      return ['西']; // 返回需要避開的方位
    }

    // 根據運勢類型調整方位
    switch (fortune.type) {
      case '學習':
        if (!directions.contains('東')) directions.add('東');
        break;
      case '事業':
        if (!directions.contains('南')) directions.add('南');
        break;
      case '財運':
        if (!directions.contains('西')) directions.add('西');
        break;
      case '人際':
        if (!directions.contains('北')) directions.add('北');
        break;
    }

    return directions;
  }

  // 獲取建議的活動方向
  String getDirectionAdvice(Fortune fortune, CompassDirection currentDirection) {
    final luckyDirections = getLuckyDirections(fortune);
    
    // 如果當前方位是吉利方位
    if (_compassService.isLuckyDirection(currentDirection, luckyDirections)) {
      return '當前方位適合進行${fortune.type}相關活動';
    }

    // 獲取最近的吉利方位
    final nearest = _compassService.getNearestLuckyDirection(
      currentDirection,
      luckyDirections,
    );

    if (nearest != null) {
      return '建議轉向${nearest.direction}方位，以獲得更好的${fortune.type}運勢';
    }

    return '今日運勢較低，建議避免重要活動';
  }

  // 判斷當前時間是否適合特定活動
  bool isGoodTimeForActivity(Fortune fortune, DateTime time) {
    // 根據時辰判斷
    final hour = time.hour;
    
    switch (fortune.type) {
      case '學習':
        // 早上6-12點最適合學習
        return hour >= 6 && hour < 12;
      case '事業':
        // 上午9點到下午5點適合工作
        return hour >= 9 && hour < 17;
      case '財運':
        // 上午10點到下午3點適合財務活動
        return hour >= 10 && hour < 15;
      case '人際':
        // 下午2點到晚上8點適合社交
        return hour >= 14 && hour < 20;
      default:
        return true;
    }
  }

  // 獲取完整的方位建議
  String getFullDirectionAdvice(
    Fortune fortune,
    CompassDirection currentDirection,
    DateTime currentTime,
  ) {
    final timeAdvice = isGoodTimeForActivity(fortune, currentTime)
        ? '現在是進行${fortune.type}活動的好時機'
        : '建議稍後再進行${fortune.type}活動';

    final directionAdvice = getDirectionAdvice(fortune, currentDirection);

    return '$timeAdvice。$directionAdvice';
  }
} 