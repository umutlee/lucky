import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/fortune.dart';
import '../utils/logger.dart';
import 'sqlite_preferences_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => 
  StorageService(ref.read(sqlitePreferencesServiceProvider)));

/// 本地存儲服務
class StorageService {
  static const String _tag = 'StorageService';
  final _logger = Logger(_tag);
  final SQLitePreferencesService _prefsService;
  static const String _keyPrefix = 'all_lucky_';

  StorageService(this._prefsService);

  Future<void> init() async {
    try {
      await _prefsService.init();
      _logger.info('儲存服務初始化成功');
    } catch (e, stackTrace) {
      _logger.error('儲存服務初始化失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> saveString(String key, String value) async {
    try {
      return await _prefsService.setValue(key, value);
    } catch (e, stackTrace) {
      _logger.error('保存字符串失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<String?> getString(String key) async {
    try {
      return await _prefsService.getValue<String>(key);
    } catch (e, stackTrace) {
      _logger.error('獲取字符串失敗: $key', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveInt(String key, int value) async {
    try {
      return await _prefsService.setValue(key, value);
    } catch (e, stackTrace) {
      _logger.error('保存整數失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<int?> getInt(String key) async {
    try {
      return await _prefsService.getValue<int>(key);
    } catch (e, stackTrace) {
      _logger.error('獲取整數失敗: $key', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveDouble(String key, double value) async {
    try {
      return await _prefsService.setValue(key, value);
    } catch (e, stackTrace) {
      _logger.error('保存浮點數失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      return await _prefsService.getValue<double>(key);
    } catch (e, stackTrace) {
      _logger.error('獲取浮點數失敗: $key', e, stackTrace);
      return null;
    }
  }

  Future<bool> saveBool(String key, bool value) async {
    try {
      return await _prefsService.setValue(key, value);
    } catch (e, stackTrace) {
      _logger.error('保存布爾值失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      return await _prefsService.getValue<bool>(key);
    } catch (e, stackTrace) {
      _logger.error('獲取布爾值失敗: $key', e, stackTrace);
      return null;
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await _prefsService.remove(key);
    } catch (e, stackTrace) {
      _logger.error('刪除值失敗: $key', e, stackTrace);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await _prefsService.clear();
    } catch (e, stackTrace) {
      _logger.error('清除所有值失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> saveData(String key, dynamic value) async {
    final String fullKey = _keyPrefix + key;
    
    if (value is String) {
      return await _prefsService.setValue(fullKey, value);
    } else if (value is bool) {
      return await _prefsService.setValue(fullKey, value);
    } else if (value is int) {
      return await _prefsService.setValue(fullKey, value);
    } else if (value is double) {
      return await _prefsService.setValue(fullKey, value);
    } else if (value is List<String>) {
      return await _prefsService.setValue(fullKey, value);
    } else {
      // 對於複雜對象,轉換為JSON字符串存儲
      final jsonString = json.encode(value);
      return await _prefsService.setValue(fullKey, jsonString);
    }
  }

  T? getData<T>(String key) {
    final String fullKey = _keyPrefix + key;
    final value = _prefsService.getValue<T>(fullKey);
    
    if (value == null) {
      return null;
    }

    if (T == String || T == bool || T == int || T == double || T == List<String>) {
      return value as T;
    } else {
      // 對於複雜對象,從JSON字符串解析
      try {
        final jsonString = _prefsService.getValue<String>(fullKey);
        if (jsonString == null) return null;
        return json.decode(jsonString) as T;
      } catch (e) {
        print('Error decoding JSON for key $key: $e');
        return null;
      }
    }
  }

  Future<bool> removeData(String key) async {
    final String fullKey = _keyPrefix + key;
    return await _prefsService.remove(fullKey);
  }

  Future<bool> clearAll() async {
    final allKeys = _prefsService.getKeys();
    final appKeys = allKeys.where((key) => key.startsWith(_keyPrefix));
    
    for (final key in appKeys) {
      await _prefsService.remove(key);
    }
    
    return true;
  }

  bool hasKey(String key) {
    final String fullKey = _keyPrefix + key;
    return _prefsService.containsKey(fullKey);
  }

  Future<T?> getCachedFortune<T>(String key) async {
    final jsonString = _prefsService.getValue<String>(key);
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString);
      if (T == Fortune) {
        return Fortune.fromJson(json) as T;
      }
      return json as T;
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheFortune<T>(String key, T data) async {
    if (data == null) return;
    
    try {
      final jsonString = data is Fortune 
          ? jsonEncode(data.toJson())
          : jsonEncode(data);
      await _prefsService.setValue(key, jsonString);
    } catch (e) {
      // 忽略序列化錯誤
    }
  }

  Future<void> clearAllCache() async {
    final keys = _prefsService.getKeys().where((key) => key.startsWith('fortune_'));
    for (final key in keys) {
      await _prefsService.remove(key);
    }
  }

  /// 保存設置
  Future<bool> saveSettings<T>(String key, T value) async {
    try {
      final String fullKey = _keyPrefix + key;
      if (value is String) {
        return await _prefsService.setValue(fullKey, value);
      } else if (value is bool) {
        return await _prefsService.setValue(fullKey, value);
      } else if (value is int) {
        return await _prefsService.setValue(fullKey, value);
      } else if (value is double) {
        return await _prefsService.setValue(fullKey, value);
      } else if (value is List<String>) {
        return await _prefsService.setValue(fullKey, value);
      } else {
        final jsonString = json.encode(value);
        return await _prefsService.setValue(fullKey, jsonString);
      }
    } catch (e, stackTrace) {
      _logger.error('保存設置失敗: $key', e, stackTrace);
      return false;
    }
  }

  /// 獲取設置
  T? getSettings<T>(String key) {
    try {
      final String fullKey = _keyPrefix + key;
      final value = _prefsService.getValue<T>(fullKey);
      
      if (value == null) {
        return null;
      }

      if (T == String || T == bool || T == int || T == double || T == List<String>) {
        return value as T;
      } else {
        final jsonString = _prefsService.getValue<String>(fullKey);
        if (jsonString == null) return null;
        return json.decode(jsonString) as T;
      }
    } catch (e, stackTrace) {
      _logger.error('獲取設置失敗: $key', e, stackTrace);
      return null;
    }
  }
} 