import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';
import 'package:all_lucky/core/utils/error_handler.dart';
import 'package:all_lucky/core/storage/database/database_manager.dart';

/// 緩存管理器提供者
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  return CacheManager(databaseManager);
});

/// 緩存管理器
/// 統一管理所有緩存操作，支持內存緩存和持久化存儲
class CacheManager {
  static const String _tag = 'CacheManager';
  final _logger = Logger(_tag);
  final DatabaseManager _databaseManager;
  
  // 內存緩存
  final Map<String, dynamic> _memoryCache = {};
  
  CacheManager(this._databaseManager);

  /// 設置緩存
  Future<void> set(
    String key,
    dynamic value, {
    Duration? expiration,
    bool persistToDisk = true,
  }) async {
    try {
      // 設置內存緩存
      _memoryCache[key] = value;

      if (persistToDisk) {
        final expiresAt = expiration != null
            ? DateTime.now().add(expiration)
            : DateTime.now().add(const Duration(days: 1));

        await _databaseManager.insert(
          'cache',
          {
            'key': key,
            'value': jsonEncode(value),
            'expires_at': expiresAt.toIso8601String(),
          },
        );
      }
    } catch (e, stackTrace) {
      _logger.error('設置緩存失敗: $key', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '設置緩存失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 獲取緩存
  Future<T?> get<T>(String key) async {
    try {
      // 先檢查內存緩存
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key] as T;
      }

      // 從數據庫獲取
      final results = await _databaseManager.query(
        'cache',
        where: 'key = ? AND expires_at > ?',
        whereArgs: [key, DateTime.now().toIso8601String()],
      );

      if (results.isEmpty) {
        return null;
      }

      final value = jsonDecode(results.first['value'] as String);
      
      // 更新內存緩存
      _memoryCache[key] = value;
      
      return value as T;
    } catch (e, stackTrace) {
      _logger.error('獲取緩存失敗: $key', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '獲取緩存失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 刪除緩存
  Future<void> remove(String key) async {
    try {
      // 刪除內存緩存
      _memoryCache.remove(key);

      // 刪除數據庫緩存
      await _databaseManager.delete(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e, stackTrace) {
      _logger.error('刪除緩存失敗: $key', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '刪除緩存失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 清理過期緩存
  Future<void> clearExpired() async {
    try {
      // 清理數據庫中的過期緩存
      await _databaseManager.delete(
        'cache',
        where: 'expires_at <= ?',
        whereArgs: [DateTime.now().toIso8601String()],
      );

      // 清理內存緩存
      _memoryCache.clear();
    } catch (e, stackTrace) {
      _logger.error('清理過期緩存失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '清理過期緩存失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 清空所有緩存
  Future<void> clearAll() async {
    try {
      // 清空內存緩存
      _memoryCache.clear();

      // 清空數據庫緩存
      await _databaseManager.clearTable('cache');
    } catch (e, stackTrace) {
      _logger.error('清空緩存失敗', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '清空緩存失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 獲取或設置緩存
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() getData, {
    Duration? expiration,
    bool persistToDisk = true,
  }) async {
    try {
      final cached = await get<T>(key);
      if (cached != null) {
        return cached;
      }

      final value = await getData();
      await set(
        key,
        value,
        expiration: expiration,
        persistToDisk: persistToDisk,
      );
      return value;
    } catch (e, stackTrace) {
      _logger.error('獲取或設置緩存失敗: $key', e, stackTrace);
      throw AppError(
        ErrorType.database,
        '獲取或設置緩存失敗',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 