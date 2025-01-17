import '../models/fortune_display_config.dart';
import '../models/user_identity.dart';
import 'storage_service.dart';

/// 配置服務
class ConfigService {
  final StorageService _storage;
  
  // 配置鍵
  static const _fortuneConfigKey = 'fortune_display_config';
  static const _userIdentityKey = 'user_identity';
  static const _themeKey = 'theme';
  static const _languageKey = 'language';
  static const _notificationKey = 'notification';
  static const _zodiacKey = 'zodiac';

  ConfigService(this._storage);

  /// 獲取運勢顯示配置
  FortuneDisplayConfig? getFortuneConfig() {
    final data = _storage.getConfig<Map<String, dynamic>>(_fortuneConfigKey);
    if (data == null) return null;
    return FortuneDisplayConfig.fromJson(data);
  }

  /// 保存運勢顯示配置
  Future<void> saveFortuneConfig(FortuneDisplayConfig config) async {
    await _storage.saveConfig(_fortuneConfigKey, config.toJson());
  }

  /// 獲取用戶身份信息
  UserIdentity? getUserIdentity() {
    final data = _storage.getConfig<Map<String, dynamic>>(_userIdentityKey);
    if (data == null) return null;
    return UserIdentity.fromJson(data);
  }

  /// 保存用戶身份信息
  Future<void> saveUserIdentity(UserIdentity identity) async {
    await _storage.saveConfig(_userIdentityKey, identity.toJson());
  }

  /// 獲取主題設置
  String? getTheme() {
    return _storage.getConfig<String>(_themeKey);
  }

  /// 保存主題設置
  Future<void> saveTheme(String theme) async {
    await _storage.saveConfig(_themeKey, theme);
  }

  /// 獲取語言設置
  String? getLanguage() {
    return _storage.getConfig<String>(_languageKey);
  }

  /// 保存語言設置
  Future<void> saveLanguage(String language) async {
    await _storage.saveConfig(_languageKey, language);
  }

  /// 獲取通知設置
  Map<String, bool>? getNotificationSettings() {
    return _storage.getConfig<Map<String, bool>>(_notificationKey);
  }

  /// 保存通知設置
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    await _storage.saveConfig(_notificationKey, settings);
  }

  /// 獲取生肖設置
  String? getUserZodiac() {
    return _storage.getConfig<String>(_zodiacKey);
  }

  /// 保存生肖設置
  Future<void> saveUserZodiac(String zodiac) async {
    await _storage.saveConfig(_zodiacKey, zodiac);
  }

  /// 清除所有配置
  Future<void> clearAllConfig() async {
    final keys = [
      _fortuneConfigKey,
      _userIdentityKey,
      _themeKey,
      _languageKey,
      _notificationKey,
      _zodiacKey,
    ];

    for (final key in keys) {
      await _storage.saveConfig(key, null);
    }
  }
} 