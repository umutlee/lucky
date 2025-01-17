import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/almanac_provider.dart';
import '../../../core/providers/fortune_provider.dart';
import '../widgets/calendar_view.dart';
import '../widgets/fortune_preview.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final lunarDates = ref.watch(almanacProvider);
    final dailyFortune = ref.watch(fortuneProvider);
    final studyFortune = ref.watch(studyFortuneProvider(selectedDate));
    final careerFortune = ref.watch(careerFortuneProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('月曆'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: lunarDates.when(
              data: (dates) => CalendarView(
                selectedDate: selectedDate,
                lunarDates: dates,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('載入失敗: $error')),
            ),
          ),
          Expanded(
            child: dailyFortune.when(
              data: (data) => FortunePreview(
                date: selectedDate,
                dailyFortune: data['daily'],
                studyFortune: studyFortune.value,
                careerFortune: careerFortune.value,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('載入失敗: $error')),
            ),
          ),
        ],
      ),
    );
  }
} 