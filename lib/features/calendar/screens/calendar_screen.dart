import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/providers/study_fortune_provider.dart';
import '../../../core/providers/career_fortune_provider.dart';
import '../../../core/providers/love_fortune_provider.dart';
import '../../../core/providers/fortune_config_provider.dart';

/// 日曆畫面
class CalendarScreen extends ConsumerStatefulWidget {
  /// 構造函數
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(fortuneConfigProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('運勢日曆'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          if (_selectedDay != null) ...[
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (config.isVisible('study'))
                    _buildFortuneCard(
                      title: '學業運勢',
                      icon: Icons.school,
                      provider: dailyStudyFortuneProvider(_selectedDay!),
                    ),
                  if (config.isVisible('career'))
                    _buildFortuneCard(
                      title: '事業運勢',
                      icon: Icons.work,
                      provider: dailyCareerFortuneProvider(_selectedDay!),
                    ),
                  if (config.isVisible('love'))
                    _buildFortuneCard(
                      title: '愛情運勢',
                      icon: Icons.favorite,
                      provider: dailyLoveFortuneProvider(_selectedDay!),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFortuneCard({
    required String title,
    required IconData icon,
    required AsyncValue provider,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            provider.when(
              data: (fortune) => Text(fortune.toString()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('加載失敗: $error'),
            ),
          ],
        ),
      ),
    );
  }
} 