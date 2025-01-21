import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/user_settings.dart';
import '../models/zodiac.dart';
import '../utils/logger.dart';

final sqliteUserSettingsServiceProvider = Provider<SQLiteUserSettingsService>((ref) {
  return SQLiteUserSettingsService(ref.read(databaseHelperProvider));
});

class SQLiteUserSettingsService {
  static const String _tableName = 'user_settings';
  final DatabaseHelper _db;
  final _logger = Logger('SQLiteUserSettingsService');

  SQLiteUserSettingsService(this._db);

  Future<void> init() async {
    try {
      final hasSettings = await _hasUserSettings();
      if (!hasSettings) {
        await _initializeDefaultSettings();
      }
      _logger.info('用戶設置服務初始化成功');
    } catch (e, stack) {
      _logger.error('用戶設置服務初始化失敗', e, stack);
      rethrow;
    }
  }

  Future<bool> _hasUserSettings() async {
    final result = await _db.query(_tableName, limit: 1);
    return result.isNotEmpty;
  }

  Future<void> _initializeDefaultSettings() async {
    try {
      final defaultSettings = UserSettings.defaultSettings();
      await _saveSettings(defaultSettings);
      _logger.info('默認用戶設置初始化成功');
    } catch (e, stack) {
      _logger.error('初始化默認用戶設置失敗', e, stack);
      rethrow;
    }
  }

  Future<UserSettings> getUserSettings() async {
    try {
      final result = await _db.query(_tableName, limit: 1);
      
      if (result.isEmpty) {
        return UserSettings.defaultSettings();
      }

      return UserSettings(
        zodiac: Zodiac.values.firstWhere(
          (z) => z.toString() == result.first['zodiac'],
          orElse: () => Zodiac.rat,
        ),
        birthYear: result.first['birth_year'] as int,
        hasEnabledNotifications: result.first['has_enabled_notifications'] == 1,
        hasLocationPermission: result.first['has_location_permission'] == 1,
        hasCompletedOnboarding: result.first['has_completed_onboarding'] == 1,
        hasAcceptedTerms: result.first['has_accepted_terms'] == 1,
        hasAcceptedPrivacy: result.first['has_accepted_privacy'] == 1,
        isFirstLaunch: result.first['is_first_launch'] == 1,
      );
    } catch (e, stack) {
      _logger.error('讀取用戶設置失敗', e, stack);
      return UserSettings.defaultSettings();
    }
  }

  Future<void> updateUserZodiac(Zodiac zodiac) async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(zodiac: zodiac);
    await _saveSettings(newSettings);
  }

  Future<void> updateBirthYear(int birthYear) async {
    if (!_isValidBirthYear(birthYear)) {
      throw ArgumentError('無效的出生年份');
    }
    final currentSettings = await getUserSettings();
    final zodiac = Zodiac.fromYear(birthYear);
    final newSettings = currentSettings.copyWith(
      birthYear: birthYear,
      zodiac: zodiac,
    );
    await _saveSettings(newSettings);
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasEnabledNotifications: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> updateLocationPermission(bool granted) async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasLocationPermission: granted);
    await _saveSettings(newSettings);
  }

  Future<void> completeOnboarding() async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(
      hasCompletedOnboarding: true,
      isFirstLaunch: false,
    );
    await _saveSettings(newSettings);
  }

  Future<void> acceptTerms() async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasAcceptedTerms: true);
    await _saveSettings(newSettings);
  }

  Future<void> acceptPrivacy() async {
    final currentSettings = await getUserSettings();
    final newSettings = currentSettings.copyWith(hasAcceptedPrivacy: true);
    await _saveSettings(newSettings);
  }

  Future<void> _saveSettings(UserSettings settings) async {
    try {
      final row = {
        'zodiac': settings.zodiac.toString(),
        'birth_year': settings.birthYear,
        'has_enabled_notifications': settings.hasEnabledNotifications ? 1 : 0,
        'has_location_permission': settings.hasLocationPermission ? 1 : 0,
        'has_completed_onboarding': settings.hasCompletedOnboarding ? 1 : 0,
        'has_accepted_terms': settings.hasAcceptedTerms ? 1 : 0,
        'has_accepted_privacy': settings.hasAcceptedPrivacy ? 1 : 0,
        'is_first_launch': settings.isFirstLaunch ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final existingSettings = await _db.query(_tableName, limit: 1);
      if (existingSettings.isEmpty) {
        row['created_at'] = DateTime.now().toIso8601String();
        await _db.insert(_tableName, row);
      } else {
        await _db.update(
          _tableName,
          row,
          where: 'id = ?',
          whereArgs: [existingSettings.first['id']],
        );
      }
      
      _logger.info('用戶設置已保存');
    } catch (e, stack) {
      _logger.error('保存用戶設置失敗', e, stack);
      rethrow;
    }
  }

  bool _isValidBirthYear(int year) {
    final currentYear = DateTime.now().year;
    return year > 1900 && year <= currentYear;
  }

  // 遷移數據方法
  Future<void> migrateFromSharedPreferences(String jsonStr) async {
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final settings = UserSettings.fromJson(json);
      await _saveSettings(settings);
      _logger.info('從 SharedPreferences 遷移用戶設置成功');
    } catch (e, stack) {
      _logger.error('從 SharedPreferences 遷移用戶設置失敗', e, stack);
      rethrow;
    }
  }
} 