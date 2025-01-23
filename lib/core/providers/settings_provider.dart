import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';

/// 主題模式提供者
final themeModeProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sqlitePreferencesServiceProvider);
  return false; // 默認值，實際值會在初始化時加載
});

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return ThemeNotifier(prefsService);
});

class ThemeNotifier extends StateNotifier<bool> {
  final SQLitePreferencesService _prefsService;
  static const _key = 'isDarkMode';

  ThemeNotifier(this._prefsService) : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _prefsService.getValue<bool>(_key) ?? false;
    state = isDark;
  }

  Future<void> toggleTheme() async {
    state = !state;
    await _prefsService.setValue(_key, state);
  }
}

final notificationEnabledProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return NotificationNotifier(prefsService);
});

class NotificationNotifier extends StateNotifier<bool> {
  final SQLitePreferencesService _prefsService;
  static const _key = 'notificationsEnabled';

  NotificationNotifier(this._prefsService) : super(true) {
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _prefsService.getValue<bool>(_key) ?? true;
    state = enabled;
  }

  Future<void> toggleNotifications() async {
    state = !state;
    await _prefsService.setValue(_key, state);
  }
} 