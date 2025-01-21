import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FortuneDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? minDate;
  final DateTime? maxDate;

  const FortuneDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.minDate,
    this.maxDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy年MM月dd日', 'zh_TW');

    return Card(
      child: InkWell(
        onTap: () => _showDatePicker(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '選擇日期',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(selectedDate),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = minDate ?? now.subtract(const Duration(days: 7));
    final lastDate = maxDate ?? now.add(const Duration(days: 7));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('zh', 'TW'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      onDateChanged(pickedDate);
    }
  }
} 