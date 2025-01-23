import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return NotificationSettingsNotifier(prefsService);
});

class NotificationSettingsNotifier extends StateNotifier<bool> {
  final SQLitePreferencesService _prefsService;

  NotificationSettingsNotifier(this._prefsService) : super(true) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final enabled = await _prefsService.getValue<bool>('notifications_enabled') ?? true;
      state = enabled;
    } catch (e) {
      print('加載通知設置失敗: $e');
    }
  }

  Future<void> toggleNotifications() async {
    try {
      final newState = !state;
      await _prefsService.setValue('notifications_enabled', newState);
      state = newState;
    } catch (e) {
      print('更新通知設置失敗: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _prefsService.setValue('notifications_enabled', enabled);
      state = enabled;
    } catch (e) {
      print('設置通知狀態失敗: $e');
    }
  }
} 