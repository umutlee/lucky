import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('需要在 main.dart 中初始化 SharedPreferences');
});

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'isDarkMode';

  ThemeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  void toggleTheme() {
    state = !state;
    _prefs.setBool(_key, state);
  }
}

final notificationEnabledProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationNotifier(prefs);
});

class NotificationNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'notificationsEnabled';

  NotificationNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  void toggleNotifications() {
    state = !state;
    _prefs.setBool(_key, state);
  }
} 