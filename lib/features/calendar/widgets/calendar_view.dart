import 'package:flutter/material.dart';
import '../../../core/models/lunar_date.dart';
import '../../../shared/utils/date_converter.dart';

class CalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final List<LunarDate> lunarDates;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarView({
    super.key,
    required this.selectedDate,
    required this.lunarDates,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    
    // 計算月曆的起始日期（包含上個月的部分日期）
    final startDate = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    
    // 建立日期對照表
    final lunarDateMap = {
      for (var date in lunarDates)
        DateTime(selectedDate.year, selectedDate.month, date.day): date
    };

    return Column(
      children: [
        // 月份標題
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final previousMonth = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                    1,
                  );
                  onDateSelected(previousMonth);
                },
              ),
              Text(
                '${selectedDate.year}年 ${selectedDate.month}月',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final nextMonth = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                    1,
                  );
                  onDateSelected(nextMonth);
                },
              ),
            ],
          ),
        ),
        // 星期標題
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              WeekdayLabel('日'),
              WeekdayLabel('一'),
              WeekdayLabel('二'),
              WeekdayLabel('三'),
              WeekdayLabel('四'),
              WeekdayLabel('五'),
              WeekdayLabel('六'),
            ],
          ),
        ),
        const Divider(height: 1),
        // 日期網格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 42, // 6週 x 7天
            itemBuilder: (context, index) {
              final date = startDate.add(Duration(days: index));
              final lunarDate = lunarDateMap[date];
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isCurrentMonth = date.month == selectedDate.month;

              return DateCell(
                date: date,
                lunarDate: lunarDate,
                isSelected: isSelected,
                isToday: isToday,
                isCurrentMonth: isCurrentMonth,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WeekdayLabel extends StatelessWidget {
  final String text;

  const WeekdayLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class DateCell extends StatelessWidget {
  final DateTime date;
  final LunarDate? lunarDate;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final VoidCallback onTap;

  const DateCell({
    super.key,
    required this.date,
    this.lunarDate,
    required this.isSelected,
    required this.isToday,
    required this.isCurrentMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected
        ? theme.colorScheme.primary
        : isToday
            ? theme.colorScheme.primaryContainer
            : null;
    final textColor = isSelected
        ? theme.colorScheme.onPrimary
        : !isCurrentMonth
            ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
            : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
              ),
            ),
            if (lunarDate != null) ...[
              const SizedBox(height: 2),
              Text(
                '${lunarDate!.month}/${lunarDate!.day}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontSize: 10,
                ),
              ),
              if (lunarDate!.solarTerm != null ||
                  lunarDate!.festival != null) ...[
                const SizedBox(height: 2),
                Text(
                  lunarDate!.solarTerm ?? lunarDate!.festival!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
} 