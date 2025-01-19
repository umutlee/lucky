import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';

class PreferencePage extends ConsumerStatefulWidget {
  const PreferencePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends ConsumerState<PreferencePage> {
  final Set<String> _selectedFortuneTypes = {'學業', '事業'};
  bool _enableDailyNotification = true;
  bool _enableSolarTermNotification = true;
  bool _enableLuckyDayNotification = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '個人偏好',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '設置您感興趣的運勢類型和通知提醒',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildFortuneTypeSection(),
          const SizedBox(height: 32),
          _buildNotificationSection(),
        ],
      ),
    );
  }

  Widget _buildFortuneTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '運勢類型',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFortuneTypeChip('學業'),
            _buildFortuneTypeChip('事業'),
            _buildFortuneTypeChip('財運'),
            _buildFortuneTypeChip('愛情'),
            _buildFortuneTypeChip('健康'),
            _buildFortuneTypeChip('人際'),
          ],
        ),
      ],
    );
  }

  Widget _buildFortuneTypeChip(String type) {
    final isSelected = _selectedFortuneTypes.contains(type);
    return FilterChip(
      selected: isSelected,
      label: Text(type),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFortuneTypes.add(type);
          } else {
            _selectedFortuneTypes.remove(type);
          }
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通知設置',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildNotificationSwitch(
          title: '每日運勢提醒',
          subtitle: '在每天早上接收運勢預測通知',
          value: _enableDailyNotification,
          onChanged: (value) {
            setState(() {
              _enableDailyNotification = value;
            });
          },
        ),
        _buildNotificationSwitch(
          title: '節氣提醒',
          subtitle: '在節氣變化時接收通知',
          value: _enableSolarTermNotification,
          onChanged: (value) {
            setState(() {
              _enableSolarTermNotification = value;
            });
          },
        ),
        _buildNotificationSwitch(
          title: '吉日提醒',
          subtitle: '在重要吉日時接收通知',
          value: _enableLuckyDayNotification,
          onChanged: (value) {
            setState(() {
              _enableLuckyDayNotification = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch({
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

  bool savePreferences() {
    if (_selectedFortuneTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請至少選擇一個運勢類型')),
      );
      return false;
    }

    // 保存偏好設置
    ref.read(userProfileServiceProvider).updatePreferences(
      fortuneTypes: _selectedFortuneTypes.toList(),
      enableDailyNotification: _enableDailyNotification,
      enableSolarTermNotification: _enableSolarTermNotification,
      enableLuckyDayNotification: _enableLuckyDayNotification,
    );

    return true;
  }
} 