import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 存儲服務接口
abstract class StorageService {
  /// 緩存運勢數據
  Future<void> cacheFortune<T>(String key, T data);

  /// 獲取緩存的運勢數據
  Future<T?> getCachedFortune<T>(String key);

  /// 緩存黃曆數據
  Future<void> cacheAlmanac<T>(String key, T data);

  /// 獲取緩存的黃曆數據
  Future<T?> getCachedAlmanac<T>(String key);

  /// 保存配置
  Future<void> saveConfig<T>(String key, T value);

  /// 獲取配置
  T? getConfig<T>(String key);

  /// 清除所有緩存
  Future<void> clearAllCache();

  /// 清除過期緩存
  Future<void> clearExpiredCache();
}

/// 本地存儲服務實現
class LocalStorageService implements StorageService {
  final SharedPreferences _prefs;
  static const _fortunePrefix = 'fortune_';
  static const _almanacPrefix = 'almanac_';
  static const _configPrefix = 'config_';
  static const _fortuneExpiration = Duration(hours: 12);
  static const _almanacExpiration = Duration(days: 7);
  static const _maxCacheSize = 100;

  LocalStorageService(this._prefs);

  @override
  Future<void> cacheFortune<T>(String key, T data) async {
    final cacheKey = _fortunePrefix + key;
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _cacheData(cacheKey, cacheData, _fortuneExpiration);
  }

  @override
  Future<T?> getCachedFortune<T>(String key) async {
    final cacheKey = _fortunePrefix + key;
    final data = await _getCachedData<T>(cacheKey);
    return data;
  }

  @override
  Future<void> cacheAlmanac<T>(String key, T data) async {
    final cacheKey = _almanacPrefix + key;
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _cacheData(cacheKey, cacheData, _almanacExpiration);
  }

  @override
  Future<T?> getCachedAlmanac<T>(String key) async {
    final cacheKey = _almanacPrefix + key;
    final data = await _getCachedData<T>(cacheKey);
    return data;
  }

  @override
  Future<void> saveConfig<T>(String key, T value) async {
    final configKey = _configPrefix + key;
    final jsonStr = json.encode(value);
    await _prefs.setString(configKey, jsonStr);
  }

  @override
  T? getConfig<T>(String key) {
    final configKey = _configPrefix + key;
    final jsonStr = _prefs.getString(configKey);
    if (jsonStr == null) return null;
    
    try {
      final data = json.decode(jsonStr);
      return data as T;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_fortunePrefix) || 
          key.startsWith(_almanacPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    final keys = _prefs.getKeys();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final key in keys) {
      if (key.startsWith(_fortunePrefix) || 
          key.startsWith(_almanacPrefix)) {
        final jsonStr = _prefs.getString(key);
        if (jsonStr != null) {
          try {
            final data = json.decode(jsonStr);
            final timestamp = data['timestamp'] as int;
            final expiration = key.startsWith(_fortunePrefix) 
                ? _fortuneExpiration 
                : _almanacExpiration;
            
            if (now - timestamp > expiration.inMilliseconds) {
              await _prefs.remove(key);
            }
          } catch (e) {
            await _prefs.remove(key);
          }
        }
      }
    }
  }

  /// 內部方法：緩存數據
  Future<void> _cacheData(
    String key,
    Map<String, dynamic> data,
    Duration expiration,
  ) async {
    await _cleanupCache();
    final jsonStr = json.encode(data);
    await _prefs.setString(key, jsonStr);
  }

  /// 內部方法：獲取緩存數據
  Future<T?> _getCachedData<T>(String key) async {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;

    try {
      final data = json.decode(jsonStr);
      final timestamp = data['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiration = key.startsWith(_fortunePrefix) 
          ? _fortuneExpiration 
          : _almanacExpiration;

      if (now - timestamp > expiration.inMilliseconds) {
        await _prefs.remove(key);
        return null;
      }

      return data['data'] as T;
    } catch (e) {
      await _prefs.remove(key);
      return null;
    }
  }

  /// 內部方法：清理過多的緩存
  Future<void> _cleanupCache() async {
    final keys = _prefs.getKeys().where((key) => 
        key.startsWith(_fortunePrefix) || 
        key.startsWith(_almanacPrefix)
    ).toList();

    if (keys.length > _maxCacheSize) {
      keys.sort((a, b) {
        final aStr = _prefs.getString(a);
        final bStr = _prefs.getString(b);
        if (aStr == null || bStr == null) return 0;

        try {
          final aData = json.decode(aStr);
          final bData = json.decode(bStr);
          return (aData['timestamp'] as int)
              .compareTo(bData['timestamp'] as int);
        } catch (e) {
          return 0;
        }
      });

      for (var i = 0; i < keys.length - _maxCacheSize; i++) {
        await _prefs.remove(keys[i]);
      }
    }
  }
} 