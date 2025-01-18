import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_settings.dart';
import '../../../core/providers/notification_settings_provider.dart';
import '../../../core/utils/logger.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsNotifierProvider);
    final logger = Logger('NotificationSettingsScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              ref.read(notificationSettingsNotifierProvider.notifier).resetSettings();
            },
            tooltip: '重置設置',
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsList(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('載入設置時發生錯誤: $error'),
        ),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return ListView(
      children: [
        _buildSwitchTile(
          context,
          ref,
          title: '每日運勢提醒',
          subtitle: '在設定時間接收每日運勢更新提醒',
          value: settings.enableDailyFortune,
          onChanged: (value) {
            _updateSettings(
              ref,
              settings.copyWith(enableDailyFortune: value),
            );
          },
        ),
        if (settings.enableDailyFortune)
          ListTile(
            title: const Text('提醒時間'),
            subtitle: Text(
              '${settings.dailyNotificationTime.hour.toString().padLeft(2, '0')}:'
              '${settings.dailyNotificationTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showTimePicker(context, ref, settings),
          ),
        const Divider(),
        _buildSwitchTile(
          context,
          ref,
          title: '節氣提醒',
          subtitle: '在節氣變化前收到提醒',
          value: settings.enableSolarTerm,
          onChanged: (value) {
            _updateSettings(
              ref,
              settings.copyWith(enableSolarTerm: value),
            );
          },
        ),
        if (settings.enableSolarTerm)
          ListTile(
            title: const Text('提前提醒時間'),
            subtitle: Text('${settings.solarTermPreNotifyDuration.inDays} 天'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showDurationPicker(context, ref, settings),
          ),
        const Divider(),
        _buildSwitchTile(
          context,
          ref,
          title: '吉日提醒',
          subtitle: '在重要吉日到來前收到提醒',
          value: settings.enableLuckyDay,
          onChanged: (value) {
            _updateSettings(
              ref,
              settings.copyWith(enableLuckyDay: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: settings.dailyNotificationTime,
    );

    if (newTime != null) {
      _updateSettings(
        ref,
        settings.copyWith(dailyNotificationTime: newTime),
      );
    }
  }

  Future<void> _showDurationPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final int? days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇提前提醒時間'),
        content: DropdownButton<int>(
          value: settings.solarTermPreNotifyDuration.inDays,
          items: [1, 2, 3, 5, 7].map((days) {
            return DropdownMenuItem<int>(
              value: days,
              child: Text('$days 天'),
            );
          }).toList(),
          onChanged: (value) {
            Navigator.of(context).pop(value);
          },
        ),
      ),
    );

    if (days != null) {
      _updateSettings(
        ref,
        settings.copyWith(
          solarTermPreNotifyDuration: Duration(days: days),
        ),
      );
    }
  }

  void _updateSettings(WidgetRef ref, NotificationSettings newSettings) {
    ref.read(notificationSettingsNotifierProvider.notifier)
        .updateSettings(newSettings);
  }
} 