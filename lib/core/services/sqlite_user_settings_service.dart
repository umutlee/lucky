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
  final DatabaseHelper _dbHelper;
  final _logger = Logger('SQLiteUserSettingsService');
  static const _tableName = 'user_settings';

  SQLiteUserSettingsService(this._dbHelper);

  Future<void> init() async {
    try {
      final db = await _dbHelper.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          zodiac TEXT NOT NULL,
          birth_year INTEGER NOT NULL,
          notifications_enabled INTEGER DEFAULT 1,
          location_permission_granted INTEGER DEFAULT 0,
          onboarding_completed INTEGER DEFAULT 0,
          terms_accepted INTEGER DEFAULT 0,
          privacy_accepted INTEGER DEFAULT 0,
          is_first_launch INTEGER DEFAULT 1,
          preferred_fortune_types TEXT,
          notification_time TEXT,
          selected_language TEXT,
          selected_theme TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 檢查是否需要初始化默認設置
      final settings = await getUserSettings();
      if (settings == null) {
        await _saveSettings(UserSettings.defaultSettings());
      }
    } catch (e, stackTrace) {
      _logger.error('初始化用戶設置服務失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<UserSettings?> getUserSettings() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(_tableName, limit: 1);
      
      if (results.isEmpty) {
        return null;
      }

      final map = results.first;
      return UserSettings(
        zodiac: Zodiac.values.firstWhere(
          (z) => z.toString() == map['zodiac'] as String,
          orElse: () => Zodiac.rat,
        ),
        birthYear: map['birth_year'] as int,
        notificationsEnabled: map['notifications_enabled'] == 1,
        locationPermissionGranted: map['location_permission_granted'] == 1,
        onboardingCompleted: map['onboarding_completed'] == 1,
        termsAccepted: map['terms_accepted'] == 1,
        privacyAccepted: map['privacy_accepted'] == 1,
        isFirstLaunch: map['is_first_launch'] == 1,
        preferredFortuneTypes: _decodeStringList(map['preferred_fortune_types']),
        notificationTime: map['notification_time'] as String?,
        selectedLanguage: map['selected_language'] as String?,
        selectedTheme: map['selected_theme'] as String?,
      );
    } catch (e, stackTrace) {
      _logger.error('獲取用戶設置失敗', e, stackTrace);
      return null;
    }
  }

  Future<void> updateUserZodiac(Zodiac zodiac) async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(zodiac: zodiac);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新用戶生肖失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateBirthYear(int birthYear) async {
    if (!_isValidBirthYear(birthYear)) {
      throw ArgumentError('無效的出生年份');
    }

    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final zodiac = Zodiac.fromYear(birthYear);
      final newSettings = settings.copyWith(
        birthYear: birthYear,
        zodiac: zodiac,
      );
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新出生年份失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(notificationsEnabled: enabled);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新通知設置失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateLocationPermission(bool granted) async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(locationPermissionGranted: granted);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新位置權限失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(
        onboardingCompleted: true,
        isFirstLaunch: false,
      );
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('完成引導失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> acceptTerms() async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(termsAccepted: true);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('接受條款失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> acceptPrivacy() async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(privacyAccepted: true);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('接受隱私政策失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePreferredFortuneTypes(List<String> types) async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(preferredFortuneTypes: types);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新偏好運勢類型失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateNotificationTime(String time) async {
    if (!_isValidTimeFormat(time)) {
      throw ArgumentError('無效的時間格式');
    }

    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(notificationTime: time);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新通知時間失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(selectedLanguage: language);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新語言設置失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTheme(String theme) async {
    try {
      final settings = await getUserSettings();
      if (settings == null) {
        throw Exception('未找到用戶設置');
      }
      
      final newSettings = settings.copyWith(selectedTheme: theme);
      await _saveSettings(newSettings);
    } catch (e, stackTrace) {
      _logger.error('更新主題設置失敗', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _saveSettings(UserSettings settings) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(_tableName);
      await db.insert(_tableName, {
        'zodiac': settings.zodiac.toString(),
        'birth_year': settings.birthYear,
        'notifications_enabled': settings.hasEnabledNotifications ? 1 : 0,
        'location_permission_granted': settings.hasLocationPermission ? 1 : 0,
        'onboarding_completed': settings.hasCompletedOnboarding ? 1 : 0,
        'terms_accepted': settings.hasAcceptedTerms ? 1 : 0,
        'privacy_accepted': settings.hasAcceptedPrivacy ? 1 : 0,
        'is_first_launch': settings.isFirstLaunch ? 1 : 0,
        'preferred_fortune_types': _encodeStringList(settings.preferredFortuneTypes),
        'notification_time': settings.notificationTime,
        'selected_language': settings.selectedLanguage,
        'selected_theme': settings.selectedTheme,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      _logger.error('保存用戶設置失敗', e, stackTrace);
      rethrow;
    }
  }

  bool _isValidBirthYear(int year) {
    final currentYear = DateTime.now().year;
    return year > 1900 && year <= currentYear;
  }

  bool _isValidTimeFormat(String time) {
    final pattern = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return pattern.hasMatch(time);
  }

  String _encodeStringList(List<String> list) {
    return jsonEncode(list);
  }

  List<String> _decodeStringList(dynamic value) {
    if (value == null) return [];
    try {
      final List<dynamic> list = jsonDecode(value as String);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
} 