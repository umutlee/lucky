import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';
import '../theme/identity_theme.dart';
import 'fortune_config_provider.dart';
import 'storage_provider.dart';
import 'user_identity_provider.dart';
import '../services/storage_service.dart';

/// 主題模式提供者
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
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
class ThemeModeNotifier extends StateNotifier<bool> {
  final StorageService _storage;
  static const _key = 'theme_mode_is_dark';

  ThemeModeNotifier(this._storage) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final isDark = await _storage.getBool(_key);
    state = isDark ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    await _storage.setBool(_key, state);
  }
} 