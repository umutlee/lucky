import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/fortune.dart';
import '../models/user_settings.dart';
import 'zodiac_fortune_service.dart';
import 'user_settings_service.dart';
import '../services/cache_service.dart';
import '../utils/logger.dart';
import 'dart:async';

final fortuneServiceProvider = Provider<FortuneService>((ref) {
  final zodiacFortuneService = ref.watch(zodiacFortuneServiceProvider);
  final userSettingsService = ref.watch(userSettingsServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return FortuneService(zodiacFortuneService, userSettingsService, cacheService);
});

class FortuneService {
  final ZodiacFortuneService _zodiacFortuneService;
  final UserSettingsService _userSettingsService;
  final CacheService _cacheService;
  final _uuid = const Uuid();
  final _logger = Logger('FortuneService');
  static const _cacheDuration = Duration(hours: 12);

  FortuneService(this._zodiacFortuneService, this._userSettingsService, this._cacheService);

  // 生成運勢
  Future<Fortune> generateFortune(String type) async {
    // 獲取用戶設置
    final userSettings = await _userSettingsService.loadSettings();
    
    // 基礎運勢分數（根據各種因素計算）
    final baseScore = _calculateBaseScore(type, userSettings);
    
    // 生成基礎運勢對象
    final baseFortune = Fortune(
      id: _uuid.v4(),
      description: _generateDescription(type, baseScore),
      score: baseScore,
      type: type,
      date: DateTime.now(),
      recommendations: _generateBaseRecommendations(type, baseScore),
      zodiac: userSettings.zodiac,
      zodiacAffinity: {},
    );
    
    // 使用生肖運勢服務增強運勢
    return _zodiacFortuneService.enhanceFortuneWithZodiac(
      baseFortune,
      userSettings.zodiac,
    );
  }

  // 計算基礎運勢分數
  int _calculateBaseScore(String type, UserSettings settings) {
    // 基礎隨機分數
    final random = DateTime.now().millisecondsSinceEpoch % 41 + 30; // 30-70的基礎分數
    
    // 根據用戶偏好調整分數
    if (settings.preferredFortuneTypes.contains(type)) {
      return (random * 1.2).round().clamp(0, 100); // 偏好類型有加成
    }
    
    return random;
  }

  // 生成基礎描述
  String _generateDescription(String type, int score) {
    if (score >= 80) {
      return '今天的$type運勢非常好，充滿機遇';
    } else if (score >= 60) {
      return '今天的$type運勢不錯，保持平常心';
    } else if (score >= 40) {
      return '今天的$type運勢普通，需要多加努力';
    } else {
      return '今天的$type運勢欠佳，謹慎行事';
    }
  }

  // 生成基礎建議
  List<String> _generateBaseRecommendations(String type, int score) {
    final recommendations = <String>[];
    
    // 根據運勢類型生成建議
    switch (type) {
      case '學習':
        if (score >= 80) {
          recommendations.add('今天是學習新知識的好時機');
          recommendations.add('可以嘗試挑戰困難的課題');
        } else if (score >= 60) {
          recommendations.add('循序漸進地學習效果會更好');
        } else {
          recommendations.add('建議複習已學過的內容');
          recommendations.add('避免操之過急');
        }
        break;
        
      case '事業':
        if (score >= 80) {
          recommendations.add('適合展開新的工作計劃');
          recommendations.add('與同事合作會有好結果');
        } else if (score >= 60) {
          recommendations.add('按部就班完成工作任務');
        } else {
          recommendations.add('謹慎處理重要決策');
          recommendations.add('多做準備和規劃');
        }
        break;
        
      case '財運':
        if (score >= 80) {
          recommendations.add('可以考慮新的投資機會');
          recommendations.add('財務決策較為順利');
        } else if (score >= 60) {
          recommendations.add('適合理財規劃和預算');
        } else {
          recommendations.add('避免重大財務決策');
          recommendations.add('注意開支控制');
        }
        break;
        
      case '人際':
        if (score >= 80) {
          recommendations.add('適合社交活動和建立新關係');
          recommendations.add('溝通會很順暢');
        } else if (score >= 60) {
          recommendations.add('保持良好的人際互動');
        } else {
          recommendations.add('避免衝突和爭執');
          recommendations.add('多聆聽少說話');
        }
        break;
        
      default:
        if (score >= 80) {
          recommendations.add('今天運勢很好，可以多嘗試新事物');
        } else if (score >= 60) {
          recommendations.add('保持平常心，按計劃行事');
        } else {
          recommendations.add('凡事多加小心，避免衝動');
        }
    }
    
    return recommendations;
  }

  Future<Fortune?> getDailyFortune(String date, String zodiac, String constellation) async {
    final cacheKey = 'fortune:daily:$date:$zodiac:$constellation';
    
    try {
      // 嘗試從緩存獲取
      final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        _logger.info('緩存命中: $cacheKey');
        return Fortune.fromJson(cached);
      }

      // 從 API 獲取數據
      final fortune = await _fetchDailyFortune(date, zodiac, constellation);
      if (fortune != null) {
        // 存入緩存
        await _cacheService.set(
          cacheKey,
          fortune.toJson(),
          expiration: _cacheDuration,
        );
        _logger.info('緩存更新: $cacheKey');
      }
      
      return fortune;
    } catch (e, stack) {
      _logger.error('獲取運勢失敗', e, stack);
      return null;
    }
  }

  Future<List<Fortune>> getFortuneHistory(String zodiac, String constellation, {int limit = 7}) async {
    final cacheKey = 'fortune:history:$zodiac:$constellation:$limit';
    
    try {
      // 嘗試從緩存獲取
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        _logger.info('歷史記錄緩存命中: $cacheKey');
        return cached.map((e) => Fortune.fromJson(e as Map<String, dynamic>)).toList();
      }

      // 從 API 獲取數據
      final history = await _fetchFortuneHistory(zodiac, constellation, limit);
      if (history.isNotEmpty) {
        // 存入緩存
        await _cacheService.set(
          cacheKey,
          history.map((f) => f.toJson()).toList(),
          expiration: _cacheDuration,
        );
        _logger.info('歷史記錄緩存更新: $cacheKey');
      }
      
      return history;
    } catch (e, stack) {
      _logger.error('獲取歷史記錄失敗', e, stack);
      return [];
    }
  }

  Future<void> clearFortuneCache() async {
    try {
      await _cacheService.clear();
      _logger.info('運勢緩存已清空');
    } catch (e, stack) {
      _logger.error('清空緩存失敗', e, stack);
    }
  }

  // 實際的 API 調用方法
  Future<Fortune?> _fetchDailyFortune(String date, String zodiac, String constellation) async {
    try {
      final fortune = await _zodiacFortuneService.getDailyFortune(
        date: date,
        zodiac: zodiac,
        constellation: constellation,
      );
      return fortune;
    } catch (e, stack) {
      _logger.error('API 調用失敗', e, stack);
      return null;
    }
  }

  Future<List<Fortune>> _fetchFortuneHistory(String zodiac, String constellation, int limit) async {
    try {
      final history = await _zodiacFortuneService.getFortuneHistory(
        zodiac: zodiac,
        constellation: constellation,
        limit: limit,
      );
      return history;
    } catch (e, stack) {
      _logger.error('API 調用失敗', e, stack);
      return [];
    }
  }

  // 預加載下一天的運勢
  Future<void> preloadNextDayFortune(String zodiac, String constellation) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final date = tomorrow.toIso8601String().split('T')[0];
    
    final cacheKey = 'fortune:daily:$date:$zodiac:$constellation';
    
    try {
      // 檢查是否已經緩存
      final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        _logger.info('明日運勢已緩存: $cacheKey');
        return;
      }

      // 預加載明日運勢
      final fortune = await _fetchDailyFortune(date, zodiac, constellation);
      if (fortune != null) {
        await _cacheService.set(
          cacheKey,
          fortune.toJson(),
          expiration: _cacheDuration,
        );
        _logger.info('明日運勢預加載完成: $cacheKey');
      }
    } catch (e, stack) {
      _logger.error('預加載運勢失敗', e, stack);
    }
  }

  // 批量預加載歷史運勢
  Future<void> preloadHistoryFortunes(String zodiac, String constellation) async {
    final cacheKey = 'fortune:history:$zodiac:$constellation:30';
    
    try {
      // 檢查是否已經緩存
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        _logger.info('歷史運勢已緩存: $cacheKey');
        return;
      }

      // 預加載30天歷史運勢
      final history = await _fetchFortuneHistory(zodiac, constellation, 30);
      if (history.isNotEmpty) {
        await _cacheService.set(
          cacheKey,
          history.map((f) => f.toJson()).toList(),
          expiration: const Duration(days: 1),
        );
        _logger.info('歷史運勢預加載完成: $cacheKey');
      }
    } catch (e, stack) {
      _logger.error('預加載歷史運勢失敗', e, stack);
    }
  }

  // 清理過期緩存
  Future<void> cleanExpiredCache() async {
    try {
      final stats = _cacheService.getStats();
      _logger.info('清理前緩存統計: $stats');
      
      // 清理過期數據
      await _cacheService.clear();
      
      final newStats = _cacheService.getStats();
      _logger.info('清理後緩存統計: $newStats');
    } catch (e, stack) {
      _logger.error('清理過期緩存失敗', e, stack);
    }
  }

  // 獲取緩存統計信息
  Map<String, int> getCacheStats() {
    return _cacheService.getStats();
  }

  // 初始化緩存系統
  Future<void> initializeCache() async {
    try {
      _logger.info('開始初始化緩存系統');
      
      // 清理過期緩存
      await cleanExpiredCache();
      
      // 預熱緩存
      await warmupCache();
      
      // 設置定期清理任務
      _setupPeriodicCacheCleaning();
      
      // 設置定期健康檢查
      _setupPeriodicHealthCheck();
      
      _logger.info('緩存系統初始化完成');
    } catch (e, stack) {
      _logger.error('緩存系統初始化失敗', e, stack);
    }
  }

  // 設置定期清理任務
  void _setupPeriodicCacheCleaning() {
    // 每天凌晨2點清理緩存
    Timer.periodic(const Duration(days: 1), (timer) async {
      final now = DateTime.now();
      if (now.hour == 2) {
        _logger.info('開始執行定期緩存清理');
        await cleanExpiredCache();
      }
    });
  }

  // 設置定期健康檢查
  void _setupPeriodicHealthCheck() {
    // 每小時檢查一次緩存健康狀況
    Timer.periodic(const Duration(hours: 1), (timer) async {
      _logger.info('開始執行定期緩存健康檢查');
      final health = await checkCacheHealth();
      
      if (health['overallStatus'] == 'poor') {
        _logger.warning('緩存健康狀況不佳,需要注意');
        // 如果狀況不佳,可以觸發清理或其他維護操作
        await cleanExpiredCache();
      }
      
      _logger.info('緩存健康檢查完成: ${health['overallStatus']}');
    });
  }

  // 在用戶設置更新時重新加載緩存
  Future<void> reloadCacheForUser() async {
    try {
      _logger.info('開始重新加載用戶緩存');
      
      final settings = await _userSettingsService.getUserSettings();
      if (settings != null) {
        await Future.wait([
          preloadNextDayFortune(
            settings.zodiac,
            settings.constellation,
          ),
          preloadHistoryFortunes(
            settings.zodiac,
            settings.constellation,
          ),
        ]);
      }
      
      _logger.info('用戶緩存重新加載完成');
    } catch (e, stack) {
      _logger.error('重新加載用戶緩存失敗', e, stack);
    }
  }

  // 緩存預熱
  Future<void> warmupCache() async {
    try {
      _logger.info('開始緩存預熱');
      
      final settings = await _userSettingsService.getUserSettings();
      if (settings == null) {
        _logger.info('未找到用戶設置,跳過緩存預熱');
        return;
      }

      // 預熱今日運勢
      final today = DateTime.now().toIso8601String().split('T')[0];
      await getDailyFortune(today, settings.zodiac, settings.constellation);
      
      // 預熱明日運勢
      await preloadNextDayFortune(settings.zodiac, settings.constellation);
      
      // 預熱最近7天歷史
      await getFortuneHistory(settings.zodiac, settings.constellation, limit: 7);
      
      // 預熱30天歷史(後台進行)
      unawaited(preloadHistoryFortunes(settings.zodiac, settings.constellation));
      
      _logger.info('緩存預熱完成');
    } catch (e, stack) {
      _logger.error('緩存預熱失敗', e, stack);
    }
  }

  // 檢查緩存健康狀況
  Future<Map<String, dynamic>> checkCacheHealth() async {
    try {
      final stats = getCacheStats();
      final hitRate = stats['hitRatio'] ?? 0;
      
      // 檢查緩存命中率
      final hitRateStatus = hitRate >= 80 ? 'good' : (hitRate >= 60 ? 'fair' : 'poor');
      
      // 檢查內存使用
      final memoryUsage = stats['memoryUsage'] ?? 0;
      final memoryStatus = memoryUsage < 50000000 ? 'good' : (memoryUsage < 100000000 ? 'fair' : 'poor');
      
      // 檢查過期項目比例
      final totalItems = stats['totalHits'] ?? 0;
      final expiredItems = stats['misses'] ?? 0;
      final expiredRate = totalItems > 0 ? (expiredItems / totalItems * 100).round() : 0;
      final expiryStatus = expiredRate <= 20 ? 'good' : (expiredRate <= 40 ? 'fair' : 'poor');
      
      return {
        'hitRate': {
          'value': hitRate,
          'status': hitRateStatus,
        },
        'memoryUsage': {
          'value': memoryUsage,
          'status': memoryStatus,
        },
        'expiryRate': {
          'value': expiredRate,
          'status': expiryStatus,
        },
        'overallStatus': _calculateOverallStatus(hitRateStatus, memoryStatus, expiryStatus),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e, stack) {
      _logger.error('檢查緩存健康狀況失敗', e, stack);
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  String _calculateOverallStatus(String hitRate, String memory, String expiry) {
    final scores = {
      'good': 3,
      'fair': 2,
      'poor': 1,
    };
    
    final totalScore = scores[hitRate]! + scores[memory]! + scores[expiry]!;
    final avgScore = totalScore / 3;
    
    if (avgScore >= 2.5) return 'good';
    if (avgScore >= 1.5) return 'fair';
    return 'poor';
  }

  // 智能緩存預取
  Future<void> smartPreload() async {
    try {
      _logger.info('開始智能緩存預取');
      
      final settings = await _userSettingsService.getUserSettings();
      if (settings == null) return;

      // 獲取緩存統計
      final stats = getCacheStats();
      final hitRate = stats['hitRatio'] ?? 0;
      
      // 根據命中率調整預取策略
      if (hitRate < 60) {
        // 命中率低,增加預取數量
        _logger.info('命中率較低,增加預取範圍');
        await Future.wait([
          getFortuneHistory(settings.zodiac, settings.constellation, limit: 14),
          preloadNextDayFortune(settings.zodiac, settings.constellation),
        ]);
      } else if (hitRate < 80) {
        // 命中率中等,保持標準預取
        await getFortuneHistory(settings.zodiac, settings.constellation, limit: 7);
      }
      // 命中率高,減少預取以節省資源
      
      _logger.info('智能緩存預取完成');
    } catch (e, stack) {
      _logger.error('智能緩存預取失敗', e, stack);
    }
  }

  // 緩存優化
  Future<void> optimizeCache() async {
    try {
      _logger.info('開始緩存優化');
      
      final health = await checkCacheHealth();
      
      // 根據健康狀況採取不同策略
      switch (health['overallStatus']) {
        case 'poor':
          // 狀況不佳,執行完整優化
          await cleanExpiredCache();
          await warmupCache();
          break;
          
        case 'fair':
          // 狀況一般,執行智能預取
          await smartPreload();
          break;
          
        case 'good':
          // 狀況良好,僅清理過期項目
          await cleanExpiredCache();
          break;
      }
      
      _logger.info('緩存優化完成');
    } catch (e, stack) {
      _logger.error('緩存優化失敗', e, stack);
    }
  }

  // 自適應緩存過期時間
  Duration _getAdaptiveCacheDuration(String type) {
    final stats = getCacheStats();
    final hitRate = stats['hitRatio'] ?? 0;
    
    // 根據命中率動態調整緩存時間
    if (hitRate >= 80) {
      // 命中率高,延長緩存時間
      return const Duration(hours: 24);
    } else if (hitRate >= 60) {
      // 命中率中等,使用標準緩存時間
      return _cacheDuration;
    } else {
      // 命中率低,縮短緩存時間
      return const Duration(hours: 6);
    }
  }
} 