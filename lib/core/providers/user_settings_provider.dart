import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_settings_service.dart';
import 'package:all_lucky/core/models/user_settings.dart';

final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  return UserSettingsService();
});

final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final settingsService = ref.watch(userSettingsServiceProvider);
  return settingsService.getSettings();
}); 