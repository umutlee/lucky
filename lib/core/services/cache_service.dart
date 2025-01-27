import 'dart:async';
import 'dart:convert';
import '../database/database_helper.dart';
import '../utils/logger.dart';

/// 緩存服務工廠
class CacheServiceFactory {
  static CacheService create(DatabaseHelper databaseHelper) {
    return CacheServiceImpl(databaseHelper);
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

/// 緩存項目
class CacheItem<T> {
  /// 緩存數據
  final T data;
  
  /// 過期時間
  final DateTime expiresAt;
  
  /// 創建時間
  final DateTime createdAt;
  
  /// 最後訪問時間
  DateTime lastAccessedAt;
  
  /// 訪問次數
  int accessCount;
  
  CacheItem({
    required this.data,
    required this.expiresAt,
    required this.createdAt,
    required this.lastAccessedAt,
    this.accessCount = 0,
  });
  
  /// 檢查是否過期
  bool isExpired() {
    return DateTime.now().isAfter(expiresAt);
  }
  
  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'accessCount': accessCount,
    };
  }
  
  /// 從 JSON 創建
  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      data: json['data'],
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt']),
      accessCount: json['accessCount'],
    );
  }
}

/// 緩存服務接口
abstract class CacheService {
  /// 設置緩存
  Future<void> set(String key, dynamic value, {CacheConfig? config});
  
  /// 獲取緩存
  Future<T?> get<T>(String key, T Function(dynamic) fromJson, {CacheConfig? config});
  
  /// 移除緩存
  Future<void> remove(String key);
  
  /// 清空緩存
  Future<void> clear();
  
  /// 獲取緩存統計信息
  Future<Map<String, int>> getStats();
}

/// 緩存服務實現
class CacheServiceImpl implements CacheService {
  final DatabaseHelper _databaseHelper;
  final _logger = Logger();
  final Map<String, CacheItem> _memoryCache = {};
  
  CacheServiceImpl(this._databaseHelper);
  
  @override
  Future<void> set(String key, dynamic value, {CacheConfig? config}) async {
    final now = DateTime.now();
    final item = CacheItem(
      data: value,
      expiresAt: now.add(config?.expiration ?? const Duration(hours: 1)),
      createdAt: now,
      lastAccessedAt: now,
    );
    
    // 檢查最大緩存數量
    if (_memoryCache.length >= (config?.maxItems ?? 1000)) {
      _removeOldestItem();
    }
    
    _memoryCache[key] = item;
    
    if (config?.isPersistent ?? false) {
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
  }
  
  @override
  Future<T?> get<T>(String key, T Function(dynamic) fromJson, {CacheConfig? config}) async {
    // 先從內存緩存中獲取
    final memoryItem = _memoryCache[key];
    if (memoryItem != null) {
      if (memoryItem.isExpired()) {
        _memoryCache.remove(key);
        return null;
      }
      
      memoryItem.lastAccessedAt = DateTime.now();
      memoryItem.accessCount++;
      return fromJson(memoryItem.data);
    }
    
    // 如果配置為持久化，則從數據庫中獲取
    if (config?.isPersistent ?? false) {
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
          
          return fromJson(item.data);
        }
      } catch (e, stackTrace) {
        _logger.error('Failed to get cache from database', e, stackTrace);
      }
    }
    
    return null;
  }
  
  @override
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    
    try {
      await _databaseHelper.delete(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to remove cache', e, stackTrace);
    }
  }
  
  @override
  Future<void> clear() async {
    _memoryCache.clear();
    
    try {
      await _databaseHelper.delete('cache');
    } catch (e, stackTrace) {
      _logger.error('Failed to clear cache', e, stackTrace);
    }
  }
  
  @override
  Future<Map<String, int>> getStats() async {
    final stats = {
      'volatile': _memoryCache.length,
      'persistent': 0,
      'total': _memoryCache.length,
      'total_access_count': _memoryCache.values.fold(0, (sum, item) => sum + item.accessCount),
    };
    
    try {
      final results = await _databaseHelper.query('cache');
      stats['persistent'] = results.length;
      stats['total'] = stats['volatile']! + stats['persistent']!;
      
      for (final row in results) {
        final json = jsonDecode(row['value']);
        final item = CacheItem.fromJson(json);
        stats['total_access_count'] = stats['total_access_count']! + item.accessCount;
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to get cache statistics', e, stackTrace);
    }
    
    return stats;
  }
  
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
} 