import 'dart:convert';
import '../services/sqlite_preferences_service.dart';

class CacheManager {
  static const String _prefix = 'fortune_cache_';
  static const String _expiryPrefix = 'fortune_cache_expiry_';
  
  final SQLitePreferencesService _prefsService;
  
  CacheManager(this._prefsService);
  
  static Future<CacheManager> initialize(SQLitePreferencesService prefsService) async {
    return CacheManager(prefsService);
  }

  Future<T?> get<T>(String key) async {
    final fullKey = _prefix + key;
    final expiryKey = _expiryPrefix + key;
    
    // 檢查是否過期
    final expiryTimestamp = await _prefsService.getValue<int>(expiryKey);
    if (expiryTimestamp != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      if (DateTime.now().isAfter(expiryTime)) {
        // 緩存已過期，清除數據
        await Future.wait([
          _prefsService.remove(fullKey),
          _prefsService.remove(expiryKey),
        ]);
        return null;
      }
    }
    
    // 獲取緩存數據
    final jsonString = await _prefsService.getValue<String>(fullKey);
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString);
      return _deserialize<T>(json);
    } catch (e) {
      // 數據格式錯誤，清除緩存
      await Future.wait([
        _prefsService.remove(fullKey),
        _prefsService.remove(expiryKey),
      ]);
      return null;
    }
  }

  Future<void> set<T>(String key, T value, Duration ttl) async {
    final fullKey = _prefix + key;
    final expiryKey = _expiryPrefix + key;
    final expiryTime = DateTime.now().add(ttl);
    
    try {
      final json = _serialize(value);
      final jsonString = jsonEncode(json);
      
      await Future.wait([
        _prefsService.setValue(fullKey, jsonString),
        _prefsService.setValue(expiryKey, expiryTime.millisecondsSinceEpoch),
      ]);
    } catch (e) {
      // 序列化失敗，清除緩存
      await Future.wait([
        _prefsService.remove(fullKey),
        _prefsService.remove(expiryKey),
      ]);
    }
  }

  Future<void> remove(String key) async {
    final fullKey = _prefix + key;
    final expiryKey = _expiryPrefix + key;
    
    await Future.wait([
      _prefsService.remove(fullKey),
      _prefsService.remove(expiryKey),
    ]);
  }

  Future<void> clear() async {
    final keys = await _prefsService.getKeys();
    final cacheKeys = keys.where((key) => 
      key.startsWith(_prefix) || key.startsWith(_expiryPrefix)
    );
    
    await Future.wait(
      cacheKeys.map((key) => _prefsService.remove(key)),
    );
  }

  dynamic _serialize(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) {
      return {
        'type': 'datetime',
        'value': value.toIso8601String(),
      };
    }
    
    if (value is Map) {
      return {
        'type': 'map',
        'value': value.map((k, v) => MapEntry(k.toString(), _serialize(v))),
      };
    }
    
    if (value is List) {
      return {
        'type': 'list',
        'value': value.map((v) => _serialize(v)).toList(),
      };
    }
    
    if (value is Set) {
      return {
        'type': 'set',
        'value': value.map((v) => _serialize(v)).toList(),
      };
    }
    
    return value;
  }

  dynamic _deserialize<T>(dynamic json) {
    if (json == null) return null;
    
    if (json is Map && json['type'] != null) {
      switch (json['type']) {
        case 'datetime':
          return DateTime.parse(json['value']);
        case 'map':
          return (json['value'] as Map).map(
            (k, v) => MapEntry(k, _deserialize(v)),
          );
        case 'list':
          return (json['value'] as List).map((v) => _deserialize(v)).toList();
        case 'set':
          return (json['value'] as List).map((v) => _deserialize(v)).toSet();
      }
    }
    
    return json;
  }

  Future<void> saveToCache(String key, String value) async {
    await _prefsService.setValue(key, value);
  }

  Future<String?> getFromCache(String key) async {
    return await _prefsService.getValue<String>(key);
  }

  Future<void> clearCache() async {
    final keys = await _prefsService.getKeys();
    await Future.wait(
      keys.map((key) => _prefsService.remove(key))
    );
  }
} 