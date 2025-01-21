import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';
import 'package:all_lucky/core/services/database_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return CacheService(databaseService);
});

class CacheService {
  static const String _tableName = 'cache_records';
  final DatabaseService _databaseService;
  final _logger = Logger('CacheService');
  final _memoryCache = <String, dynamic>{};
  final _stats = _CacheStats();

  CacheService(this._databaseService);

  // LRU 緩存，用於存儲最近使用的數據
  final _lruCache = _LruCache<String, dynamic>(maxSize: 100);

  // 緩存統計
  int _hits = 0;
  int _misses = 0;

  Future<void> set(
    String key,
    dynamic value, {
    Duration? expiration,
    bool useMemoryCache = true,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = expiration != null ? now.add(expiration) : null;
      final jsonValue = json.encode(value);

      await _databaseService.transaction((txn) async {
        await txn.insert(
          _tableName,
          {
            'key': key,
            'value': jsonValue,
            'created_at': now.toIso8601String(),
            'expires_at': expiresAt?.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      if (useMemoryCache) {
        _memoryCache[key] = value;
      }

      _stats.incrementWrites();
      _logger.info('緩存設置成功: $key');
    } catch (e, stack) {
      _logger.error('緩存設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> setMultiple(
    Map<String, dynamic> entries, {
    Duration? expiration,
    bool useMemoryCache = true,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = expiration != null ? now.add(expiration) : null;

      await _databaseService.transaction((txn) async {
        for (final entry in entries.entries) {
          final jsonValue = json.encode(entry.value);
          await txn.insert(
            _tableName,
            {
              'key': entry.key,
              'value': jsonValue,
              'created_at': now.toIso8601String(),
              'expires_at': expiresAt?.toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      if (useMemoryCache) {
        _memoryCache.addAll(entries);
      }

      _stats.incrementWrites(entries.length);
      _logger.info('批量緩存設置成功: ${entries.length} 條記錄');
    } catch (e, stack) {
      _logger.error('批量緩存設置失敗', e, stack);
      rethrow;
    }
  }

  Future<T?> get<T>(String key) async {
    // 先檢查內存緩存
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as T?;
    }

    final results = await _databaseService.query(
      _tableName,
      where: 'key = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [key, DateTime.now().toIso8601String()],
    );

    if (results.isNotEmpty) {
      final value = json.decode(results.first['value']) as T?;
      _memoryCache[key] = value; // 更新內存緩存
      return value;
    }
    
    return null;
  }

  Future<Map<String, T?>> getMultiple<T>(
    List<String> keys, {
    bool useMemoryCache = true,
  }) async {
    try {
      final result = <String, T?>{};
      final keysToFetch = <String>[];

      if (useMemoryCache) {
        for (final key in keys) {
          if (_memoryCache.containsKey(key)) {
            result[key] = _memoryCache[key] as T?;
            _stats.incrementMemoryHits();
          } else {
            keysToFetch.add(key);
          }
        }
      } else {
        keysToFetch.addAll(keys);
      }

      if (keysToFetch.isNotEmpty) {
        final results = await _databaseService.query(
          _tableName,
          where: 'key IN (${List.filled(keysToFetch.length, '?').join(',')}) '
              'AND (expires_at IS NULL OR expires_at > ?)',
          whereArgs: [...keysToFetch, DateTime.now().toIso8601String()],
        );

        for (final row in results) {
          final key = row['key'] as String;
          final value = json.decode(row['value'] as String) as T?;
          result[key] = value;
          
          if (useMemoryCache) {
            _memoryCache[key] = value;
          }
          
          _stats.incrementDiskHits();
        }

        _stats.incrementMisses(keysToFetch.length - results.length);
      }

      return result;
    } catch (e, stack) {
      _logger.error('批量緩存獲取失敗', e, stack);
      rethrow;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _databaseService.delete(
        _tableName,
        where: 'key = ?',
        whereArgs: [key],
      );

      _memoryCache.remove(key);
      _logger.info('緩存刪除成功: $key');
    } catch (e, stack) {
      _logger.error('緩存刪除失敗', e, stack);
      rethrow;
    }
  }

  Future<void> removeMultiple(List<String> keys) async {
    try {
      await _databaseService.transaction((txn) async {
        await txn.delete(
          _tableName,
          where: 'key IN (${List.filled(keys.length, '?').join(',')})',
          whereArgs: keys,
        );
      });

      for (final key in keys) {
        _memoryCache.remove(key);
      }

      _logger.info('批量緩存刪除成功: ${keys.length} 條記錄');
    } catch (e, stack) {
      _logger.error('批量緩存刪除失敗', e, stack);
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      await _databaseService.clearTable(_tableName);
      _memoryCache.clear();
      _stats.reset();
      _logger.info('緩存清空成功');
    } catch (e, stack) {
      _logger.error('緩存清空失敗', e, stack);
      rethrow;
    }
  }

  Future<bool> has(String key) async {
    try {
      if (_memoryCache.containsKey(key)) {
        return true;
      }

      final results = await _databaseService.query(
        _tableName,
        where: 'key = ? AND (expires_at IS NULL OR expires_at > ?)',
        whereArgs: [key, DateTime.now().toIso8601String()],
      );

      return results.isNotEmpty;
    } catch (e, stack) {
      _logger.error('緩存檢查失敗', e, stack);
      rethrow;
    }
  }

  Map<String, int> getStats() {
    return _stats.toMap();
  }
}

class _CacheStats {
  int memoryHits = 0;
  int diskHits = 0;
  int misses = 0;
  int writes = 0;

  void incrementMemoryHits([int count = 1]) => memoryHits += count;
  void incrementDiskHits([int count = 1]) => diskHits += count;
  void incrementMisses([int count = 1]) => misses += count;
  void incrementWrites([int count = 1]) => writes += count;

  void reset() {
    memoryHits = 0;
    diskHits = 0;
    misses = 0;
    writes = 0;
  }

  Map<String, int> toMap() {
    return {
      'memoryHits': memoryHits,
      'diskHits': diskHits,
      'misses': misses,
      'writes': writes,
      'totalHits': memoryHits + diskHits,
      'hitRatio': _calculateHitRatio(),
    };
  }

  int _calculateHitRatio() {
    final totalOperations = memoryHits + diskHits + misses;
    if (totalOperations == 0) return 0;
    return ((memoryHits + diskHits) * 100 ~/ totalOperations);
  }
}

class _LruCache<K, V> {
  final int maxSize;
  final _cache = LinkedHashMap<K, V>();

  _LruCache({required this.maxSize});

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;
    if (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  void remove(K key) => _cache.remove(key);
  void clear() => _cache.clear();
  bool containsKey(K key) => _cache.containsKey(key);
} 