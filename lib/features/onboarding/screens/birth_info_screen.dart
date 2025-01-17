import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_identity.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../../../core/theme/identity_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

/// 生辰八字輸入頁面
class BirthInfoScreen extends ConsumerStatefulWidget {
  final UserIdentity selectedIdentity;

  const BirthInfoScreen({
    super.key,
    required this.selectedIdentity,
  });

  @override
  ConsumerState<BirthInfoScreen> createState() => _BirthInfoScreenState();
}

class _BirthInfoScreenState extends ConsumerState<BirthInfoScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLunarCalendar = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = IdentityTheme.getThemeForIdentity(widget.selectedIdentity.type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('生辰八字'),
        actions: [
          TextButton(
            onPressed: () => _skipBirthInfo(context),
            child: const Text('稍後再說'),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.secondaryColor,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCalendarTypeSwitch(),
            const SizedBox(height: 24),
            _buildDatePicker(context),
            const SizedBox(height: 24),
            _buildTimePicker(context),
            const SizedBox(height: 32),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTypeSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '日曆類型',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('陽曆'),
                    value: false,
                    groupValue: _isLunarCalendar,
                    onChanged: (value) {
                      setState(() => _isLunarCalendar = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('農曆'),
                    value: true,
                    groupValue: _isLunarCalendar,
                    onChanged: (value) {
                      setState(() => _isLunarCalendar = value!);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_isLunarCalendar ? "農曆" : "陽曆"}生日',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '出生時辰',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                '${_selectedTime.hour}時${_selectedTime.minute}分',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.check),
      label: const Text('確認'),
      onPressed: () => _submitBirthInfo(context),
    );
  }

  void _skipBirthInfo(BuildContext context) async {
    // 設置默認值
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_birth_info', false);
    
    if (context.mounted) {
      context.go('/home');
    }
  }

  void _submitBirthInfo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 計算生肖和星座
    final chineseZodiac = ChineseZodiac.fromYear(_selectedDate.year);
    final horoscope = Horoscope.fromDate(_selectedDate);
    
    // 保存生辰八字信息
    final birthInfo = {
      'date': _selectedDate.toIso8601String(),
      'time': '${_selectedTime.hour}:${_selectedTime.minute}',
      'is_lunar': _isLunarCalendar,
      'chinese_zodiac': {
        'name': chineseZodiac.name,
        'image_path': chineseZodiac.imagePath,
      },
      'horoscope': {
        'name': horoscope.name,
        'image_path': horoscope.imagePath,
      },
    };
    
    await prefs.setString('birth_info', jsonEncode(birthInfo));
    await prefs.setBool('has_birth_info', true);
    
    if (context.mounted) {
      context.go('/home');
    }
  }
} 