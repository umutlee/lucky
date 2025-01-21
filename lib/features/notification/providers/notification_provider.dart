import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/core/utils/logger.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<bool> {
  final NotificationService _notificationService;

  NotificationNotifier({NotificationService? service})
      : _notificationService = service ?? NotificationService(),
        super(false);

  Future<void> initialize() async {
    try {
      final result = await _notificationService.initialize();
      state = result;
      if (state) {
        AppLogger.i('通知提供者初始化成功');
      } else {
        AppLogger.e('通知提供者初始化失敗');
      }
    } catch (e, stackTrace) {
      state = false;
      AppLogger.e('通知提供者初始化失敗', e, stackTrace);
    }
  }

  Future<void> scheduleFortuneNotification(DateTime scheduledTime) async {
    if (!state) {
      AppLogger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.scheduleFortuneNotification(scheduledTime);
    } catch (e, stackTrace) {
      AppLogger.e('排程運勢通知失敗', e, stackTrace);
    }
  }

  Future<void> showFortuneNotification(String message) async {
    if (!state) {
      AppLogger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.showFortuneNotification(message);
    } catch (e, stackTrace) {
      AppLogger.e('發送運勢通知失敗', e, stackTrace);
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!state) {
      AppLogger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.cancelAllNotifications();
    } catch (e, stackTrace) {
      AppLogger.e('取消所有通知失敗', e, stackTrace);
    }
  }
} 