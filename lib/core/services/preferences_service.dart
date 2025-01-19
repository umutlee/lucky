import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:all_lucky/core/models/user_preferences.dart';
import 'package:all_lucky/core/utils/logger.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

class PreferencesService {
  static const String _boxName = 'preferences';
  static const String _preferencesKey = 'user_preferences';
  late Box<UserPreferences> _box;
  UserPreferences? _preferences;
  final _logger = Logger('PreferencesService');

  Future<void> init() async {
    try {
      Hive.registerAdapter(UserPreferencesAdapter());
      _box = await Hive.openBox<UserPreferences>(_boxName);
      _loadPreferences();
    } catch (e, stack) {
      _logger.error('初始化偏好設置失敗', e, stack);
      rethrow;
    }
  }

  void _loadPreferences() {
    try {
      _preferences = _box.get(_preferencesKey) ?? UserPreferences();
    } catch (e, stack) {
      _logger.error('加載偏好設置失敗', e, stack);
      _preferences = UserPreferences();
    }
  }

  UserPreferences get preferences => _preferences ?? UserPreferences();

  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      await _box.put(_preferencesKey, preferences);
      _preferences = preferences;
    } catch (e, stack) {
      _logger.error('更新偏好設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> updateNotificationSettings({
    bool? enableDailyNotification,
    bool? enableSolarTermNotification,
    bool? enableLuckyDayNotification,
    String? notificationTime,
  }) async {
    try {
      final updatedPreferences = preferences.copyWith(
        enableDailyNotification: enableDailyNotification,
        enableSolarTermNotification: enableSolarTermNotification,
        enableLuckyDayNotification: enableLuckyDayNotification,
        notificationTime: notificationTime,
      );
      await updatePreferences(updatedPreferences);
    } catch (e, stack) {
      _logger.error('更新通知設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> updateFortuneTypes(List<String> fortuneTypes) async {
    try {
      final updatedPreferences = preferences.copyWith(
        preferredFortuneTypes: fortuneTypes,
      );
      await updatePreferences(updatedPreferences);
    } catch (e, stack) {
      _logger.error('更新運勢類型失敗', e, stack);
      rethrow;
    }
  }

  Future<void> updateLanguageStyle(String style) async {
    try {
      final updatedPreferences = preferences.copyWith(
        languageStyle: style,
      );
      await updatePreferences(updatedPreferences);
    } catch (e, stack) {
      _logger.error('更新語言風格失敗', e, stack);
      rethrow;
    }
  }

  Future<void> updateDarkMode(bool enableDarkMode) async {
    try {
      final updatedPreferences = preferences.copyWith(
        enableDarkMode: enableDarkMode,
      );
      await updatePreferences(updatedPreferences);
    } catch (e, stack) {
      _logger.error('更新深色模式設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> updateCustomSettings(Map<String, dynamic> settings) async {
    try {
      final updatedPreferences = preferences.copyWith(
        customSettings: settings,
      );
      await updatePreferences(updatedPreferences);
    } catch (e, stack) {
      _logger.error('更新自定義設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> resetPreferences() async {
    try {
      await _box.delete(_preferencesKey);
      _preferences = UserPreferences();
    } catch (e, stack) {
      _logger.error('重置偏好設置失敗', e, stack);
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _box.close();
  }
} 