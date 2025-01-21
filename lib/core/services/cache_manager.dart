import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/almanac_repository.dart';
import '../repositories/fortune_repository.dart';
import '../services/cache_service.dart';
import '../utils/logger.dart';

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager(
    ref.watch(almanacRepositoryProvider),
    ref.watch(fortuneRepositoryProvider),
    ref.watch(cacheServiceProvider),
  );
});

class CacheManager {
  final AlmanacRepository _almanacRepository;
  final FortuneRepository _fortuneRepository;
  final CacheService _cacheService;
  final _logger = Logger('CacheManager');

  CacheManager(
    this._almanacRepository,
    this._fortuneRepository,
    this._cacheService,
  );

  /// 清理所有過期緩存
  Future<void> clearExpiredCache() async {
    try {
      await Future.wait([
        _almanacRepository.clearExpiredCache(),
        _fortuneRepository.clearExpiredCache(),
        _cacheService.clear(),
      ]);
      _logger.info('清理過期緩存完成');
    } catch (e, stack) {
      _logger.error('清理過期緩存失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取緩存統計信息
  Map<String, dynamic> getCacheStats() {
    return {
      'memory': _cacheService.getStats(),
      'database': {
        'almanac': _almanacRepository.getCacheStats(),
        'fortune': _fortuneRepository.getCacheStats(),
      },
    };
  }

  /// 清理所有緩存
  Future<void> clearAllCache() async {
    try {
      await _cacheService.clear();
      await _almanacRepository.clearAllCache();
      await _fortuneRepository.clearAllCache();
      _logger.info('清理所有緩存完成');
    } catch (e, stack) {
      _logger.error('清理所有緩存失敗', e, stack);
      rethrow;
    }
  }
} 