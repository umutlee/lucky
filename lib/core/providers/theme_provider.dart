import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';
import '../theme/identity_theme.dart';
import 'fortune_config_provider.dart';

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
  static const String _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(_loadInitialMode(_prefs));

  static ThemeMode _loadInitialMode(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value != null) {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == value,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }

  /// 更新主題模式
  Future<void> updateThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.toString());
  }
} 