import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/services/user_profile_service.dart';
import 'package:all_lucky/core/services/notification_service.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/utils/logger.dart';

class PreferencePage extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const PreferencePage({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  @override
  ConsumerState<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends ConsumerState<PreferencePage> {
  final _logger = Logger('PreferencePage');
  Set<FortuneType> _selectedFortuneTypes = {};
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  bool _enableDailyFortune = true;
  bool _enableSolarTerm = true;
  bool _enableLuckyDay = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final userProfile = ref.read(userProfileServiceProvider).currentProfile;
      if (userProfile != null) {
        setState(() {
          _selectedFortuneTypes = Set.from(userProfile.preferredFortuneTypes);
          _enableDailyFortune = userProfile.notificationSettings.enableDailyFortune;
          _enableSolarTerm = userProfile.notificationSettings.enableSolarTerm;
          _enableLuckyDay = userProfile.notificationSettings.enableLuckyDay;
          _notificationTime = userProfile.notificationSettings.notificationTime;
        });
      }
      _logger.info('成功加載用戶偏好設置');
    } catch (e) {
      _logger.error('加載用戶偏好設置失敗: $e');
      _showErrorSnackBar('無法加載已保存的偏好設置');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  Widget _buildFortuneTypeSection() {
    final fortuneTypes = [
      FortuneType(
        id: 'overall',
        name: '總運',
        icon: Icons.auto_awesome,
        description: '綜合運勢預測',
      ),
      FortuneType(
        id: 'career',
        name: '事業運',
        icon: Icons.work,
        description: '工作與事業發展',
      ),
      FortuneType(
        id: 'wealth',
        name: '財運',
        icon: Icons.attach_money,
        description: '財富與收入',
      ),
      FortuneType(
        id: 'love',
        name: '感情運',
        icon: Icons.favorite,
        description: '感情與人際關係',
      ),
      FortuneType(
        id: 'study',
        name: '學業運',
        icon: Icons.school,
        description: '學習與考試',
      ),
      FortuneType(
        id: 'health',
        name: '健康運',
        icon: Icons.favorite_border,
        description: '身心健康',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '運勢類型',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '選擇您感興趣的運勢類型',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortuneTypes.map((type) {
            final isSelected = _selectedFortuneTypes.contains(type);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedFortuneTypes.add(type);
                  } else {
                    _selectedFortuneTypes.remove(type);
                  }
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        if (_selectedFortuneTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '請至少選擇一種運勢類型',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
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
        const SizedBox(height: 8),
        Text(
          '設置您想要接收的通知類型',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('每日運勢提醒'),
          subtitle: const Text('每天提醒您查看運勢'),
          value: _enableDailyFortune,
          onChanged: (bool value) {
            setState(() {
              _enableDailyFortune = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('節氣提醒'),
          subtitle: const Text('在節氣變化時提醒您'),
          value: _enableSolarTerm,
          onChanged: (bool value) {
            setState(() {
              _enableSolarTerm = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('吉日提醒'),
          subtitle: const Text('在重要吉日時提醒您'),
          value: _enableLuckyDay,
          onChanged: (bool value) {
            setState(() {
              _enableLuckyDay = value;
            });
          },
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('通知時間'),
          subtitle: Text(
            '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _selectNotificationTime,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: widget.formKey,
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
      ),
    );
  }

  bool validatePreferences() {
    if (_selectedFortuneTypes.isEmpty) {
      _showErrorSnackBar('請至少選擇一種運勢類型');
      return false;
    }
    return true;
  }

  Future<void> savePreferences() async {
    if (!validatePreferences()) return;

    try {
      final notificationSettings = NotificationSettings(
        enableDailyFortune: _enableDailyFortune,
        enableSolarTerm: _enableSolarTerm,
        enableLuckyDay: _enableLuckyDay,
        notificationTime: _notificationTime,
      );

      await ref.read(userProfileServiceProvider).updatePreferences(
        fortuneTypes: _selectedFortuneTypes.toList(),
        notificationSettings: notificationSettings,
      );

      if (_enableDailyFortune) {
        await ref.read(notificationServiceProvider).scheduleDailyFortuneNotification(
          _notificationTime,
        );
      }

      _logger.info('成功保存用戶偏好設置');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('偏好設置保存成功'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _logger.error('保存用戶偏好設置失敗: $e');
      _showErrorSnackBar('保存失敗：${e.toString()}');
    }
  }
} 