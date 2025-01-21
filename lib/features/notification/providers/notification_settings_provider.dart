import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/sqlite_preferences_service.dart';
import '../../../core/utils/logger.dart';

class NotificationSettings {
  final bool isEnabled;
  final String notificationTime;
  final bool isInitialized;

  NotificationSettings({
    required this.isEnabled,
    required this.notificationTime,
    this.isInitialized = false,
  });

  static NotificationSettings get initial => NotificationSettings(
    isEnabled: true,
    notificationTime: '08:00',
  );

  NotificationSettings copyWith({
    bool? isEnabled,
    String? notificationTime,
    bool? isInitialized,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final SQLitePreferencesService _preferencesService;
  final _logger = Logger('NotificationSettingsNotifier');

  NotificationSettingsNotifier(this._preferencesService) : super(NotificationSettings.initial) {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      final isEnabled = await _preferencesService.getDailyNotification();
      final notificationTime = await _preferencesService.getNotificationTime();
      
      state = NotificationSettings(
        isEnabled: isEnabled,
        notificationTime: notificationTime,
        isInitialized: true,
      );
      
      _logger.info('通知設置初始化成功');
    } catch (e, stack) {
      _logger.error('通知設置初始化失敗', e, stack);
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await _preferencesService.setDailyNotification(enabled);
      state = state.copyWith(isEnabled: enabled);
      _logger.info('更新通知開關狀態: $enabled');
    } catch (e, stack) {
      _logger.error('更新通知開關狀態失敗', e, stack);
      rethrow;
    }
  }

  Future<void> setNotificationTime(String time) async {
    try {
      await _preferencesService.setNotificationTime(time);
      state = state.copyWith(notificationTime: time);
      _logger.info('更新通知時間: $time');
    } catch (e, stack) {
      _logger.error('更新通知時間失敗', e, stack);
      rethrow;
    }
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref.read(sqlitePreferencesServiceProvider));
}); 