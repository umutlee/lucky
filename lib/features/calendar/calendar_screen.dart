import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/almanac_provider.dart';
import '../../core/providers/fortune_provider.dart';
import 'widgets/calendar_view.dart';
import 'widgets/fortune_preview.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final lunarDates = ref.watch(monthLunarDatesProvider(selectedDate));
    final fortunes = ref.watch(monthFortunesProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('月曆'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
            tooltip: '回到今天',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: lunarDates.when(
              data: (dates) => CalendarView(
                selectedDate: selectedDate,
                lunarDates: dates,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
              ),
              error: (error, stack) => Center(
                child: Text('載入月曆資料失敗: $error'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: fortunes.when(
              data: (data) => FortunePreview(
                date: selectedDate,
                fortune: data[selectedDate],
              ),
              error: (error, stack) => Center(
                child: Text('載入運勢資料失敗: $error'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 