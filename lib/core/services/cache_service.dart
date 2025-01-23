import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  final _cache = HashMap<String, _CacheEntry>();
  final _logger = Logger('CacheService');
  static const _maxSize = 100;
  static const _defaultExpiry = Duration(minutes: 30);

  CacheService._internal();

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T;
  }

  void put<T>(String key, T value) {
    // 如果緩存已滿，移除最舊的項目
    if (_cache.length >= _maxSize) {
      final oldestKey = _cache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _cache.remove(oldestKey);
    }

    _cache[key] = _CacheEntry(value);
    _logger.info('緩存設置成功: $key');
  }

  void remove(String key) {
    _cache.remove(key);
    _logger.info('緩存刪除成功: $key');
  }

  void clear() {
    _cache.clear();
    _logger.info('緩存清空成功');
  }

  // 清理過期的緩存項目
  void cleanup() {
    final beforeSize = _cache.length;
    _cache.removeWhere((_, entry) => entry.isExpired);
    final afterSize = _cache.length;
    _logger.info('緩存清理完成: 刪除 ${beforeSize - afterSize} 條過期記錄');
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;
  static const _expiry = Duration(minutes: 30);

  _CacheEntry(this.value) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > _expiry;
} 