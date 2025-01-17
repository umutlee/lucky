import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';
import '../theme/identity_theme.dart';
import 'fortune_config_provider.dart';
import 'storage_provider.dart';

/// 主題模式提供者
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// 身份主題提供者
final identityThemeProvider = Provider<IdentityTheme>((ref) {
  final identity = ref.watch(userIdentityProvider);
  return IdentityTheme.getThemeForIdentity(identity.type);
});

/// 主題數據提供者
final themeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final identityTheme = ref.watch(identityThemeProvider);
  
  final brightness = switch (themeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
  };
  
  return identityTheme.createTheme(brightness);
});

/// 主題模式管理器
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadInitialThemeMode(_prefs));

  static ThemeMode _loadInitialThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_themeModePrefKey);
    return savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString(_themeModePrefKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    state = newMode;
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_themeModePrefKey, mode == ThemeMode.dark ? 'dark' : 'light');
    state = mode;
  }
} 