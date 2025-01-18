import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';
import '../models/user_settings.dart';
import '../utils/zodiac_image_helper.dart';

final userSettingsServiceProvider = Provider((ref) => UserSettingsService());

class UserSettingsService {
  static const _settingsKey = 'user_settings';
  
  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return UserSettings.fromJson(json);
      } catch (e) {
        return UserSettings.defaultSettings();
      }
    }
    
    return UserSettings.defaultSettings();
  }
  
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }
  
  // 根據出生年份計算生肖
  String calculateZodiac(int birthYear) {
    final zodiacOrder = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];
    final index = (birthYear - 4) % 12; // 以4年為鼠年起始
    return zodiacOrder[index];
  }
  
  // 驗證生肖是否有效
  bool isValidZodiac(String zodiac) {
    return ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'].contains(zodiac);
  }
  
  // 驗證出生年份是否有效（假設用戶年齡在1-120歲之間）
  bool isValidBirthYear(int birthYear) {
    final currentYear = DateTime.now().year;
    return birthYear > currentYear - 120 && birthYear <= currentYear;
  }
  
  // 更新用戶生肖設置
  Future<void> updateUserZodiac(String zodiac) async {
    if (!isValidZodiac(zodiac)) {
      throw ArgumentError('無效的生肖: $zodiac');
    }
    
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(zodiac: zodiac);
    await saveSettings(newSettings);
  }
  
  // 更新用戶出生年份
  Future<void> updateBirthYear(int birthYear) async {
    if (!isValidBirthYear(birthYear)) {
      throw ArgumentError('無效的出生年份: $birthYear');
    }
    
    final currentSettings = await loadSettings();
    final zodiac = calculateZodiac(birthYear);
    final newSettings = currentSettings.copyWith(
      birthYear: birthYear,
      zodiac: zodiac,
    );
    await saveSettings(newSettings);
  }
  
  // 更新通知設置
  Future<void> updateNotificationSettings(bool enabled) async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(enableNotifications: enabled);
    await saveSettings(newSettings);
  }
  
  // 更新偏好運勢類型
  Future<void> updatePreferredFortuneTypes(List<String> types) async {
    final currentSettings = await loadSettings();
    final newSettings = currentSettings.copyWith(preferredFortuneTypes: types);
    await saveSettings(newSettings);
  }
} 