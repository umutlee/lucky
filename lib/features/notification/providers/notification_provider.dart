import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/logger.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>(
  (ref) => NotificationNotifier(),
);

class NotificationNotifier extends StateNotifier<bool> {
  final _notificationService = NotificationService();
  final _logger = AppLogger();

  NotificationNotifier() : super(false);

  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      state = true;
      _logger.i('通知提供者初始化成功');
    } catch (e) {
      _logger.e('通知提供者初始化失敗', e);
      state = false;
    }
  }

  Future<void> scheduleFortuneNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!state) {
      _logger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.scheduleFortuneNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      _logger.e('排程運勢通知失敗', e);
      rethrow;
    }
  }

  Future<void> showFortuneNotification({
    required String title,
    required String body,
  }) async {
    if (!state) {
      _logger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.showFortuneNotification(
        title: title,
        body: body,
      );
    } catch (e) {
      _logger.e('發送運勢通知失敗', e);
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!state) {
      _logger.w('通知服務未初始化');
      return;
    }

    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      _logger.e('取消所有通知失敗', e);
      rethrow;
    }
  }
} 