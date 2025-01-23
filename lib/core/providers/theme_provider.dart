import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';
import '../theme/identity_theme.dart';
import 'fortune_config_provider.dart';
import 'storage_provider.dart';
import 'user_identity_provider.dart';

/// 主題模式提供者
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return ThemeModeNotifier(prefsService);
});

/// 身份主題提供者
final identityThemeProvider = Provider<IdentityTheme>((ref) {
  return IdentityTheme.defaultTheme();
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
  final SQLitePreferencesService _prefsService;

  ThemeModeNotifier(this._prefsService) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final isDark = await _prefsService.getValue<bool>('is_dark_mode') ?? false;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      print('加載主題設置失敗: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      await _prefsService.setValue('is_dark_mode', newMode == ThemeMode.dark);
      state = newMode;
    } catch (e) {
      print('更新主題設置失敗: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _prefsService.setValue('is_dark_mode', mode == ThemeMode.dark);
      state = mode;
    } catch (e) {
      print('設置主題模式失敗: $e');
    }
  }
} 