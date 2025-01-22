import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/logger.dart';

class NotificationSettings {
  final bool isEnabled;
  final DateTime notificationTime;
  final bool isInitialized;

  NotificationSettings({
    required this.isEnabled,
    required this.notificationTime,
    this.isInitialized = false,
  });

  static NotificationSettings get initial => NotificationSettings(
    isEnabled: false,
    notificationTime: DateTime(2024, 1, 1, 8, 0),
    isInitialized: false,
  );

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
  String toString() {
    return 'NotificationSettings(isEnabled: $isEnabled, isInitialized: $isInitialized, notificationTime: ${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')})';
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
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _notificationService;
  final _logger = Logger('NotificationSettingsNotifier');

  NotificationSettingsNotifier({required NotificationService service})
      : _notificationService = service,
        super(NotificationSettings.initial);

  Future<void> initialize() async {
    try {
      final success = await _notificationService.initialize();
      if (success) {
        _logger.info('通知服務初始化成功');
        state = state.copyWith(
          isEnabled: true,
          isInitialized: true,
        );
        await scheduleNextNotification();
      } else {
        _logger.warning('通知服務初始化失敗');
        state = state.copyWith(
          isEnabled: false,
          isInitialized: true,
        );
      }
    } catch (e, stack) {
      _logger.error('通知服務初始化失敗', e, stack);
      state = state.copyWith(
        isEnabled: false,
        isInitialized: true,
      );
    }
  }

  Future<bool> scheduleNextNotification() async {
    if (!state.isInitialized || !state.isEnabled) {
      _logger.warning('通知服務未初始化或未啟用');
      return false;
    }

    try {
      final now = DateTime.now();
      final todayNotificationTime = DateTime(
        now.year,
        now.month,
        now.day,
        state.notificationTime.hour,
        state.notificationTime.minute,
      );

      final scheduledTime = now.isAfter(todayNotificationTime)
          ? todayNotificationTime.add(const Duration(days: 1))
          : todayNotificationTime;

      final success = await _notificationService.scheduleFortuneNotification(scheduledTime);
      if (success) {
        _logger.info('成功排程下一次通知: $scheduledTime');
      } else {
        _logger.error('排程通知失敗');
      }
      return success;
    } catch (e, stack) {
      _logger.error('排程通知失敗', e, stack);
      return false;
    }
  }

  Future<void> toggleNotifications() async {
    if (!state.isInitialized) {
      _logger.warning('通知服務未初始化');
      return;
    }

    try {
      if (state.isEnabled) {
        final success = await _notificationService.cancelAllNotifications();
        if (success) {
          state = state.copyWith(isEnabled: false);
          _logger.info('通知已禁用');
        }
      } else {
        state = state.copyWith(isEnabled: true);
        final success = await scheduleNextNotification();
        if (!success) {
          state = state.copyWith(isEnabled: false);
        } else {
          _logger.info('通知已啟用');
        }
      }
    } catch (e, stack) {
      _logger.error('切換通知狀態失敗', e, stack);
      state = state.copyWith(isEnabled: !state.isEnabled);
      rethrow;
    }
  }

  Future<void> updateNotificationTime(DateTime newTime) async {
    if (!state.isInitialized) {
      _logger.warning('通知服務未初始化');
      return;
    }

    final originalTime = state.notificationTime;
    try {
      if (state.isEnabled) {
        final success = await _notificationService.cancelAllNotifications();
        if (!success) {
          _logger.error('取消通知失敗');
          return;
        }
      }
      
      state = state.copyWith(
        notificationTime: DateTime(
          state.notificationTime.year,
          state.notificationTime.month,
          state.notificationTime.day,
          newTime.hour,
          newTime.minute,
        ),
      );

      if (state.isEnabled) {
        final success = await scheduleNextNotification();
        if (!success) {
          // 如果排程失敗，恢復原始時間
          state = state.copyWith(notificationTime: originalTime);
          _logger.error('排程新通知失敗，恢復原始時間');
          return;
        }
      }
      
      _logger.info('通知時間已更新: ${newTime.hour}:${newTime.minute}');
    } catch (e, stack) {
      _logger.error('更新通知時間失敗', e, stack);
      // 發生錯誤時恢復原始時間
      state = state.copyWith(notificationTime: originalTime);
      rethrow;
    }
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(service: NotificationService());
}); 