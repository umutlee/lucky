import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_provider.dart';

class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calendarState = ref.watch(calendarStateProvider);

    return Card(
      child: calendarState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : calendarState.hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(calendarState.errorMessage ?? '發生錯誤'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(calendarStateProvider.notifier).updateDate(DateTime.now());
                        },
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期顯示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '農曆 ${calendarState.lunarDate}',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                calendarState.solarTerm,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                ref.read(calendarStateProvider.notifier).updateDate(date);
                              }
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 今日宜忌
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '宜',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: calendarState.goodActivities
                                      .map((activity) => Chip(
                                            label: Text(activity),
                                            backgroundColor: theme.colorScheme.primaryContainer,
                                            labelStyle: TextStyle(
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '忌',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: calendarState.badActivities
                                      .map((activity) => Chip(
                                            label: Text(activity),
                                            backgroundColor: theme.colorScheme.errorContainer,
                                            labelStyle: TextStyle(
                                              color: theme.colorScheme.onErrorContainer,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 吉時提示
                      Text(
                        '吉時',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: calendarState.luckyHours
                            .map((hour) => Chip(
                                  label: Text(hour),
                                  backgroundColor: theme.colorScheme.secondaryContainer,
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
    );
  }
} 