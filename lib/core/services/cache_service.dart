import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../utils/logger.dart';
import '../providers/providers.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  final logger = Logger('CacheService');
  final databaseHelper = ref.read(databaseHelperProvider);
  return CacheServiceImpl(databaseHelper, logger);
});

/// 緩存服務基類
abstract class CacheService {
  /// 設置緩存
  Future<void> set(String key, dynamic value, {Duration? expiry});
  
  /// 獲取緩存
  Future<dynamic> get(String key, String type);
  
  /// 刪除緩存
  Future<void> remove(String key);
  
  /// 清空緩存
  Future<void> clear();
  
  /// 檢查緩存是否存在
  Future<bool> exists(String key);
  
  /// 獲取緩存大小
  Future<int> size();
}

/// 緩存服務實現
class CacheServiceImpl implements CacheService {
  final DatabaseHelper _databaseHelper;
  final Logger _logger;
  final Map<String, CacheItem> _memoryCache = {};
  
  CacheServiceImpl(this._databaseHelper, this._logger);
  
  @override
  Future<void> set(String key, dynamic value, {Duration? expiry}) async {
    try {
      final now = DateTime.now();
      final item = CacheItem(
        data: value,
        expiresAt: expiry != null ? now.add(expiry) : null,
        createdAt: now,
        lastAccessedAt: now,
      );
      
      // 檢查最大緩存數量
      if (_memoryCache.length >= 1000) {
        _removeOldestItem();
      }
      
      _memoryCache[key] = item;
      
      // 如果設置了過期時間，則保存到數據庫
      if (expiry != null) {
        try {
          await _databaseHelper.insert(
            'cache',
            {
              'key': key,
              'value': jsonEncode(item.toJson()),
            },
            conflictResolution: 'REPLACE',
          );
        } catch (e, stackTrace) {
          _logger.error('Failed to persist cache', e, stackTrace);
        }
      }
    } catch (e, stack) {
      _logger.error('緩存設置失敗: $key', e, stack);
      rethrow;
    }
  }
  
  @override
  Future<dynamic> get(String key, String type) async {
    try {
      // 先從內存緩存中獲取
      final memoryItem = _memoryCache[key];
      if (memoryItem != null) {
        if (memoryItem.isExpired()) {
          _memoryCache.remove(key);
          return null;
        }
        
        memoryItem.lastAccessedAt = DateTime.now();
        memoryItem.accessCount++;
        return memoryItem.data;
      }
      
      // 如果內存中沒有，則從數據庫中獲取
      try {
        final results = await _databaseHelper.query(
          'cache',
          where: 'key = ?',
          whereArgs: [key],
        );
        
        if (results.isNotEmpty) {
          final json = jsonDecode(results.first['value']);
          final item = CacheItem.fromJson(json);
          
          if (item.isExpired()) {
            await _databaseHelper.delete(
              'cache',
              where: 'key = ?',
              whereArgs: [key],
            );
            return null;
          }
          
          item.lastAccessedAt = DateTime.now();
          item.accessCount++;
          
          await _databaseHelper.update(
            'cache',
            {'value': jsonEncode(item.toJson())},
            where: 'key = ?',
            whereArgs: [key],
          );
          
          return item.data;
        }
      } catch (e, stackTrace) {
        _logger.error('Failed to get cache from database', e, stackTrace);
      }
      
      return null;
    } catch (e, stack) {
      _logger.error('獲取緩存失敗: $key', e, stack);
      return null;
    }
  }
  
  @override
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      _logger.info('緩存刪除成功: $key');
      
      await _databaseHelper.delete(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e, stack) {
      _logger.error('緩存刪除失敗: $key', e, stack);
      rethrow;
    }
  }
  
  @override
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      _logger.info('緩存清空成功');
      
      await _databaseHelper.delete('cache');
    } catch (e, stack) {
      _logger.error('緩存清空失敗', e, stack);
      rethrow;
    }
  }
  
  @override
  Future<bool> exists(String key) async {
    try {
      final memoryItem = _memoryCache[key];
      if (memoryItem != null) {
        if (memoryItem.isExpired()) {
          _memoryCache.remove(key);
          return false;
        }
        return true;
      }
      
      final results = await _databaseHelper.query(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
      
      if (results.isNotEmpty) {
        final json = jsonDecode(results.first['value']);
        final item = CacheItem.fromJson(json);
        
        if (item.isExpired()) {
          await _databaseHelper.delete(
            'cache',
            where: 'key = ?',
            whereArgs: [key],
          );
          return false;
        }
        
        return true;
      }
      
      return false;
    } catch (e, stack) {
      _logger.error('檢查緩存失敗: $key', e, stack);
      return false;
    }
  }
  
  @override
  Future<int> size() async {
    try {
      // 清理過期緩存
      _cleanExpiredEntries();
      
      final memorySize = _memoryCache.length;
      final results = await _databaseHelper.query('cache');
      
      return memorySize + results.length;
    } catch (e, stack) {
      _logger.error('獲取緩存大小失敗', e, stack);
      return 0;
    }
  }
  
  /// 移除最舊的緩存項
  void _removeOldestItem() {
    if (_memoryCache.isEmpty) return;
    
    var oldestKey = _memoryCache.keys.first;
    var oldestTime = _memoryCache[oldestKey]!.lastAccessedAt;
    
    for (final entry in _memoryCache.entries) {
      if (entry.value.lastAccessedAt.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.lastAccessedAt;
      }
    }
    
    _memoryCache.remove(oldestKey);
  }
  
  /// 清理過期緩存
  void _cleanExpiredEntries() {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired())
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
  }
}

/// 緩存項
class CacheItem {
  final dynamic data;
  final DateTime? expiresAt;
  final DateTime createdAt;
  DateTime lastAccessedAt;
  int accessCount;
  
  CacheItem({
    required this.data,
    this.expiresAt,
    required this.createdAt,
    required this.lastAccessedAt,
    this.accessCount = 0,
  });
  
  bool isExpired() {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'access_count': accessCount,
    };
  }
  
  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      data: json['data'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      lastAccessedAt: DateTime.parse(json['last_accessed_at']),
      accessCount: json['access_count'] ?? 0,
    );
  }
}

/// 緩存配置
class CacheConfig {
  /// 緩存過期時間
  final Duration expiration;
  
  /// 是否持久化
  final bool isPersistent;
  
  /// 最大緩存數量
  final int maxItems;
  
  const CacheConfig({
    this.expiration = const Duration(hours: 1),
    this.isPersistent = false,
    this.maxItems = 1000,
  });
}

/// 緩存條目
class _CacheEntry {
  final dynamic value;
  final DateTime? expiryTime;
  
  _CacheEntry({
    required this.value,
    this.expiryTime,
  });
  
  bool get isExpired {
    if (expiryTime == null) {
      return false;
    }
    return DateTime.now().isAfter(expiryTime!);
  }
} 