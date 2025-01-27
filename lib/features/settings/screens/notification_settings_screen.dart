import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_settings.dart';
import '../../../core/providers/notification_settings_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isNotificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationService = ref.read(notificationServiceProvider);
    final isEnabled = await notificationService.checkPermission();
    setState(() {
      _isNotificationsEnabled = isEnabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final notificationService = ref.read(notificationServiceProvider);
    if (value) {
      final granted = await notificationService.requestPermission();
      setState(() {
        _isNotificationsEnabled = granted;
      });
      if (granted) {
        await notificationService.setDailyFortuneReminder(_selectedTime);
      }
    } else {
      await notificationService.cancelDailyFortuneReminder();
      setState(() {
        _isNotificationsEnabled = false;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      if (_isNotificationsEnabled) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.setDailyFortuneReminder(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設置'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('啟用通知'),
            subtitle: const Text('接收每日運勢提醒和其他重要通知'),
            value: _isNotificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const Divider(),
          ListTile(
            title: const Text('每日運勢提醒時間'),
            subtitle: Text(
              _selectedTime.format(context),
              style: TextStyle(
                color: _isNotificationsEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
            ),
            trailing: const Icon(Icons.access_time),
            enabled: _isNotificationsEnabled,
            onTap: _selectTime,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '開啟通知以接收：\n'
              '• 每日運勢提醒\n'
              '• 吉時提醒\n'
              '• 特殊事件通知\n'
              '• 系統更新提醒',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 