import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences.dart';
import '../models/notification_settings.dart';
import '../models/solar_term.dart';
import '../models/lucky_day.dart';
import '../services/notification_service.dart';
import '../services/solar_term_service.dart';
import '../services/lucky_day_service.dart';
import '../utils/logger.dart';

part 'notification_settings_provider.g.dart';

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  final _logger = Logger('NotificationSettingsNotifier');
  late final SharedPreferences _prefs;
  late final NotificationService _notificationService;
  late final SolarTermService _solarTermService;
  late final LuckyDayService _luckyDayService;

  @override
  Future<NotificationSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    _notificationService = NotificationService();
    _solarTermService = SolarTermService();
    _luckyDayService = LuckyDayService();
    await _notificationService.initialize();

    // 從 SharedPreferences 讀取設置
    final settingsJson = _prefs.getString('notification_settings');
    if (settingsJson != null) {
      try {
        return NotificationSettings.fromJson(
          Map<String, dynamic>.from(
            const JsonDecoder().convert(settingsJson),
          ),
        );
      } catch (e) {
        _logger.error('解析通知設置時發生錯誤', e);
      }
    }

    // 返回默認設置
    return const NotificationSettings();
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      // 更新狀態
      state = AsyncData(newSettings);

      // 保存到 SharedPreferences
      await _prefs.setString(
        'notification_settings',
        const JsonEncoder().convert(newSettings.toJson()),
      );

      // 根據新設置更新通知
      await _updateNotifications(newSettings);

      _logger.info('通知設置已更新');
    } catch (e) {
      _logger.error('更新通知設置時發生錯誤', e);
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _updateNotifications(NotificationSettings settings) async {
    try {
      // 先取消所有通知
      await _notificationService.cancelAll();

      // 如果啟用了每日運勢通知
      if (settings.enableDailyFortune) {
        await _notificationService.scheduleDailyFortuneNotification(
          settings.dailyNotificationTime,
        );
        _logger.info('已排程每日運勢通知');
      }

      // 如果啟用了節氣提醒
      if (settings.enableSolarTerm) {
        final now = DateTime.now();
        final nextTerms = await _getNextSolarTerms(now);
        
        for (final term in nextTerms) {
          // 計算提醒時間
          final notifyDate = term.date.subtract(settings.solarTermPreNotifyDuration);
          // 如果提醒時間還沒過
          if (notifyDate.isAfter(now)) {
            await _notificationService.scheduleSolarTermNotification(
              notifyDate,
              term.name,
            );
            _logger.info('已排程節氣提醒: ${term.name}');
          }
        }
      }

      // 如果啟用了吉日提醒
      if (settings.enableLuckyDay) {
        final now = DateTime.now();
        final nextLuckyDays = await _getNextLuckyDays(now);
        
        for (final luckyDay in nextLuckyDays) {
          // 提前一天提醒
          final notifyDate = luckyDay.date.subtract(const Duration(days: 1));
          // 如果提醒時間還沒過
          if (notifyDate.isAfter(now)) {
            await _notificationService.scheduleLuckyDayNotification(
              notifyDate,
              luckyDay.description,
            );
            _logger.info('已排程吉日提醒: ${luckyDay.description}');
          }
        }
      }

      _logger.info('通知已根據新設置更新');
    } catch (e) {
      _logger.error('更新通知時發生錯誤', e);
      rethrow;
    }
  }

  Future<List<SolarTerm>> _getNextSolarTerms(DateTime from) async {
    try {
      return await _solarTermService.getNextTerms(from);
    } catch (e) {
      _logger.error('獲取節氣信息失敗', e);
      return [];
    }
  }

  Future<List<LuckyDay>> _getNextLuckyDays(DateTime from) async {
    try {
      return await _luckyDayService.getNextLuckyDays(from);
    } catch (e) {
      _logger.error('獲取吉日信息失敗', e);
      return [];
    }
  }

  Future<void> resetSettings() async {
    await updateSettings(const NotificationSettings());
  }
} 