import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../models/fortune_type.dart';
import '../utils/logger.dart';

final fortuneServiceProvider = Provider<FortuneService>((ref) {
  final logger = Logger('FortuneService');
  return FortuneServiceImpl(logger: logger);
});

/// 運勢服務
abstract class FortuneService {
  /// 獲取每日運勢
  Future<Fortune> getDailyFortune(DateTime date);

  /// 獲取學業運勢
  Future<Fortune> getStudyFortune(DateTime date);

  /// 獲取事業運勢
  Future<Fortune> getCareerFortune(DateTime date);

  /// 獲取感情運勢
  Future<Fortune> getLoveFortune(DateTime date);
}

/// 運勢服務實現
class FortuneServiceImpl implements FortuneService {
  final Logger _logger;

  FortuneServiceImpl({
    required Logger logger,
  }) : _logger = logger;

  @override
  Future<Fortune> getDailyFortune(DateTime date) async {
    try {
      return Fortune(
        id: '1',
        title: '今日運勢',
        description: '今日運勢不錯，適合嘗試新事物',
        overallScore: 88,
        date: date,
        scores: {
          'study': 85,
          'career': 90,
          'love': 82,
        },
        advice: ['把握機會', '保持樂觀'],
        luckyColors: ['紅色', '金色'],
        luckyNumbers: ['6', '8'],
        luckyDirections: ['東', '南'],
        type: FortuneType.daily,
      );
    } catch (e, stack) {
      _logger.error('獲取每日運勢失敗', e, stack);
      rethrow;
    }
  }

  @override
  Future<Fortune> getStudyFortune(DateTime date) async {
    try {
      return Fortune(
        id: '2',
        title: '學業運勢',
        description: '學習效率高',
        overallScore: 85,
        date: date,
        scores: {
          'study': 85,
          'focus': 80,
          'memory': 90,
        },
        advice: ['適合考試', '記憶力好'],
        luckyColors: ['黃色'],
        luckyNumbers: ['3'],
        luckyDirections: ['東'],
        type: FortuneType.study,
      );
    } catch (e, stack) {
      _logger.error('獲取學業運勢失敗', e, stack);
      rethrow;
    }
  }

  @override
  Future<Fortune> getCareerFortune(DateTime date) async {
    try {
      return Fortune(
        id: '3',
        title: '事業運勢',
        description: '事業運勢上升',
        overallScore: 90,
        date: date,
        scores: {
          'career': 90,
          'leadership': 85,
          'teamwork': 95,
        },
        advice: ['把握機會', '展現領導力'],
        luckyColors: ['藍色'],
        luckyNumbers: ['8'],
        luckyDirections: ['南'],
        type: FortuneType.career,
      );
    } catch (e, stack) {
      _logger.error('獲取事業運勢失敗', e, stack);
      rethrow;
    }
  }

  @override
  Future<Fortune> getLoveFortune(DateTime date) async {
    try {
      return Fortune(
        id: '4',
        title: '感情運勢',
        description: '桃花運旺盛',
        overallScore: 95,
        date: date,
        scores: {
          'love': 95,
          'relationship': 90,
          'communication': 85,
        },
        advice: ['適合表白', '增進感情'],
        luckyColors: ['粉色'],
        luckyNumbers: ['2'],
        luckyDirections: ['西'],
        type: FortuneType.love,
      );
    } catch (e, stack) {
      _logger.error('獲取感情運勢失敗', e, stack);
      rethrow;
    }
  }
} 