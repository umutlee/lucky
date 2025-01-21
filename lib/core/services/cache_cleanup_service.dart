import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../services/cache_manager.dart';
import '../utils/logger.dart';

final cacheCleanupServiceProvider = Provider<CacheCleanupService>((ref) {
  return CacheCleanupService(ref.watch(cacheManagerProvider));
});

class CacheCleanupService {
  final CacheManager _cacheManager;
  final _logger = Logger('CacheCleanupService');
  Timer? _cleanupTimer;
  
  static const Duration cleanupInterval = Duration(hours: 24);
  
  CacheCleanupService(this._cacheManager);

  void startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());
    _logger.info('啟動定期緩存清理，間隔: ${cleanupInterval.inHours} 小時');
  }

  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _logger.info('停止定期緩存清理');
  }

  Future<void> _cleanup() async {
    try {
      final before = _cacheManager.getCacheStats();
      await _cacheManager.clearExpiredCache();
      final after = _cacheManager.getCacheStats();
      
      _logger.info('緩存清理完成，清理前: $before, 清理後: $after');
    } catch (e, stack) {
      _logger.error('緩存清理失敗', e, stack);
    }
  }

  void dispose() {
    stopPeriodicCleanup();
  }
} 