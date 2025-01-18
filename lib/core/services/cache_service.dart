import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final _logger = Logger('CacheService');
  
  // LRU 緩存，用於存儲最近使用的數據
  final _lruCache = _LruCache<String, dynamic>(maxSize: 100);
  
  // 弱引用緩存，用於存儲不常用的數據
  final _weakCache = WeakCache<String, dynamic>();

  // 緩存統計
  int _hits = 0;
  int _misses = 0;

  T? get<T>(String key) {
    try {
      // 先從 LRU 緩存中獲取
      var value = _lruCache.get(key);
      if (value != null) {
        _hits++;
        _logger.info('從 LRU 緩存中獲取數據: $key');
        return value as T;
      }

      // 再從弱引用緩存中獲取
      value = _weakCache.get(key);
      if (value != null) {
        // 如果從弱引用緩存中找到，則移動到 LRU 緩存
        _lruCache.put(key, value);
        _hits++;
        _logger.info('從弱引用緩存中獲取數據: $key');
        return value as T;
      }

      _misses++;
      _logger.info('緩存未命中: $key');
      return null;
    } catch (e) {
      _logger.error('獲取緩存數據失敗: $e');
      return null;
    }
  }

  void put<T>(String key, T value) {
    try {
      // 先放入 LRU 緩存
      _lruCache.put(key, value);
      // 同時放入弱引用緩存
      _weakCache.put(key, value);
      _logger.info('添加數據到緩存: $key');
    } catch (e) {
      _logger.error('添加緩存數據失敗: $e');
    }
  }

  void remove(String key) {
    try {
      _lruCache.remove(key);
      _weakCache.remove(key);
      _logger.info('從緩存中移除數據: $key');
    } catch (e) {
      _logger.error('移除緩存數據失敗: $e');
    }
  }

  void clear() {
    try {
      _lruCache.clear();
      _weakCache.clear();
      _logger.info('清空緩存');
    } catch (e) {
      _logger.error('清空緩存失敗: $e');
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