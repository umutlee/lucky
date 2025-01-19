import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import 'package:all_lucky/core/services/database_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref.read(databaseServiceProvider));
});

class CacheService {
  static const String _tableName = 'cache_records';
  final DatabaseService _database;
  final _logger = Logger('CacheService');

  CacheService(this._database);

  // LRU 緩存，用於存儲最近使用的數據
  final _lruCache = _LruCache<String, dynamic>(maxSize: 100);
  
  // 弱引用緩存，用於存儲不常用的數據
  final _weakCache = WeakCache<String, dynamic>();

  // 緩存統計
  int _hits = 0;
  int _misses = 0;

  Future<void> set(
    String key,
    dynamic value, {
    Duration? expiration,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = expiration != null 
        ? now.add(expiration)
        : null;

      await _database.insert(
        _tableName,
        {
          'key': key,
          'value': jsonEncode(value),
          'created_at': now.toIso8601String(),
          'expires_at': expiresAt?.toIso8601String(),
        },
      );

      _logger.debug('緩存數據成功: $key');
    } catch (e, stack) {
      _logger.error('緩存數據失敗: $key', e, stack);
      rethrow;
    }
  }

  Future<T?> get<T>(String key) async {
    try {
      final now = DateTime.now();
      final results = await _database.query(
        _tableName,
        where: 'key = ? AND (expires_at IS NULL OR expires_at > ?)',
        whereArgs: [key, now.toIso8601String()],
      );

      if (results.isEmpty) {
        return null;
      }

      final value = results.first['value'] as String;
      return jsonDecode(value) as T;
    } catch (e, stack) {
      _logger.error('獲取緩存數據失敗: $key', e, stack);
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _database.delete(
        _tableName,
        where: 'key = ?',
        whereArgs: [key],
      );

      _logger.debug('刪除緩存數據成功: $key');
    } catch (e, stack) {
      _logger.error('刪除緩存數據失敗: $key', e, stack);
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      await _database.clearTable(_tableName);
      _logger.info('清空緩存成功');
    } catch (e, stack) {
      _logger.error('清空緩存失敗', e, stack);
      rethrow;
    }
  }

  Future<void> clearExpired() async {
    try {
      final now = DateTime.now();
      await _database.delete(
        _tableName,
        where: 'expires_at IS NOT NULL AND expires_at <= ?',
        whereArgs: [now.toIso8601String()],
      );

      _logger.info('清理過期緩存成功');
    } catch (e, stack) {
      _logger.error('清理過期緩存失敗', e, stack);
      rethrow;
    }
  }

  Future<bool> has(String key) async {
    try {
      final now = DateTime.now();
      final results = await _database.query(
        _tableName,
        columns: ['key'],
        where: 'key = ? AND (expires_at IS NULL OR expires_at > ?)',
        whereArgs: [key, now.toIso8601String()],
      );

      return results.isNotEmpty;
    } catch (e, stack) {
      _logger.error('檢查緩存是否存在失敗: $key', e, stack);
      return false;
    }
  }

  Future<Map<String, dynamic>> getMultiple(List<String> keys) async {
    try {
      final now = DateTime.now();
      final results = await _database.query(
        _tableName,
        where: 'key IN (${List.filled(keys.length, '?').join(',')}) '
            'AND (expires_at IS NULL OR expires_at > ?)',
        whereArgs: [...keys, now.toIso8601String()],
      );

      return {
        for (var row in results)
          row['key'] as String: jsonDecode(row['value'] as String)
      };
    } catch (e, stack) {
      _logger.error('批量獲取緩存數據失敗', e, stack);
      return {};
    }
  }

  Future<void> setMultiple(Map<String, dynamic> entries, {
    Duration? expiration,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = expiration != null 
        ? now.add(expiration)
        : null;

      await Future.wait(
        entries.entries.map((entry) => _database.insert(
          _tableName,
          {
            'key': entry.key,
            'value': jsonEncode(entry.value),
            'created_at': now.toIso8601String(),
            'expires_at': expiresAt?.toIso8601String(),
          },
        )),
      );

      _logger.debug('批量緩存數據成功: ${entries.keys.join(', ')}');
    } catch (e, stack) {
      _logger.error('批量緩存數據失敗', e, stack);
      rethrow;
    }
  }

  // 獲取緩存統計信息
  Map<String, dynamic> getStats() {
    return {
      'hits': _hits,
      'misses': _misses,
      'hitRate': _hits / (_hits + _misses),
      'lruSize': _lruCache.size,
      'weakSize': _weakCache.size,
    };
  }

  // 重置統計信息
  void resetStats() {
    _hits = 0;
    _misses = 0;
  }
}

// LRU 緩存實現
class _LruCache<K, V> {
  _LruCache({required this.maxSize}) : assert(maxSize > 0);

  final int maxSize;
  final _cache = LinkedHashMap<K, V>();

  int get size => _cache.length;

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

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}

// 弱引用緩存實現
class WeakCache<K, V> {
  final _cache = <K, WeakReference<V>>{};

  int get size => _cache.length;

  V? get(K key) {
    final weakRef = _cache[key];
    if (weakRef == null) return null;

    final value = weakRef.target;
    if (value == null) {
      _cache.remove(key);
    }
    return value;
  }

  void put(K key, V value) {
    _cache[key] = WeakReference(value);
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
} 