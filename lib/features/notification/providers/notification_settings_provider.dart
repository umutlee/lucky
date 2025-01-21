import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/logger.dart';

class NotificationSettings {
  final bool isEnabled;
  final DateTime notificationTime;
  final bool isInitialized;

  NotificationSettings({
    this.isEnabled = false,
    DateTime? notificationTime,
    this.isInitialized = false,
  }) : notificationTime = notificationTime ?? _defaultNotificationTime();

  static DateTime _defaultNotificationTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 8, 0);
  }

  NotificationSettings copyWith({
    bool? isEnabled,
    DateTime? notificationTime,
    bool? isInitialized,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.isEnabled == isEnabled &&
        other.isInitialized == isInitialized &&
        other.notificationTime.hour == notificationTime.hour &&
        other.notificationTime.minute == notificationTime.minute;
  }

  @override
  int get hashCode => Object.hash(
        isEnabled,
        isInitialized,
        notificationTime.hour,
        notificationTime.minute,
      );

  @override
  String toString() => 'NotificationSettings('
      'isEnabled: $isEnabled, '
      'isInitialized: $isInitialized, '
      'notificationTime: ${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')}'
      ')';
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _notificationService;

  NotificationSettingsNotifier({NotificationService? service})
      : _notificationService = service ?? NotificationService(),
        super(NotificationSettings());

  Future<void> initialize() async {
    try {
      final result = await _notificationService.initialize();
      state = state.copyWith(
        isInitialized: true,
        isEnabled: result,
      );
      if (result) {
        AppLogger.i('通知設定提供者初始化成功');
      } else {
        AppLogger.e('通知設定提供者初始化失敗');
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        isInitialized: true,
        isEnabled: false,
      );
      AppLogger.e('通知設定提供者初始化失敗', e, stackTrace);
    }
  }

  Future<void> toggleNotifications() async {
    if (!state.isInitialized) {
      AppLogger.w('通知服務未初始化');
      return;
    }

    try {
      if (state.isEnabled) {
        await _notificationService.cancelAllNotifications();
        state = state.copyWith(isEnabled: false);
        AppLogger.i('已關閉通知');
      } else {
        await scheduleNextNotification();
        state = state.copyWith(isEnabled: true);
        AppLogger.i('已開啟通知');
      }
    } catch (e, stackTrace) {
      AppLogger.e('切換通知狀態失敗', e, stackTrace);
    }
  }

  Future<void> updateNotificationTime(DateTime time) async {
    if (!state.isInitialized) {
      AppLogger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.cancelAllNotifications();
      await _notificationService.scheduleFortuneNotification(time);
      state = state.copyWith(notificationTime: time);
      AppLogger.i('已更新通知時間: ${time.toString()}');
    } catch (e, stackTrace) {
      AppLogger.e('更新通知時間失敗', e, stackTrace);
    }
  }

  Future<void> scheduleNextNotification() async {
    if (!state.isInitialized) {
      AppLogger.w('通知服務未初始化');
      return;
    }

    try {
      final now = DateTime.now();
      final nextNotification = DateTime(
        now.year,
        now.month,
        now.day,
        state.notificationTime.hour,
        state.notificationTime.minute,
      );
      
      final scheduledTime = nextNotification.isBefore(now)
          ? nextNotification.add(const Duration(days: 1))
          : nextNotification;

      await _notificationService.scheduleFortuneNotification(scheduledTime);
      AppLogger.i('已排程下一次通知: ${scheduledTime.toString()}');
    } catch (e, stackTrace) {
      AppLogger.e('排程下一次通知失敗', e, stackTrace);
    }
  }
} 