import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/almanac_provider.dart';
import '../../../core/providers/fortune_provider.dart';
import '../widgets/calendar_view.dart';
import '../widgets/fortune_preview.dart';
import '../../home/widgets/fortune_loading_card.dart';
import '../../home/widgets/fortune_error_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final lunarDates = ref.watch(monthLunarDatesProvider(selectedDate));
    final studyFortune = ref.watch(studyFortuneProvider(selectedDate));
    final careerFortune = ref.watch(careerFortuneProvider(selectedDate));
    final loveFortune = ref.watch(loveFortuneProvider(selectedDate));

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
            flex: 3,
            child: lunarDates.when(
              data: (dates) => CalendarView(
                selectedDate: selectedDate,
                lunarDates: dates,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('載入月曆失敗: $error'),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FortunePreview(
                date: selectedDate,
                studyFortune: studyFortune.value,
                careerFortune: careerFortune.value,
                loveFortune: loveFortune.value,
                isLoading: studyFortune.isLoading || 
                          careerFortune.isLoading || 
                          loveFortune.isLoading,
                hasError: studyFortune.hasError || 
                         careerFortune.hasError || 
                         loveFortune.hasError,
                errorMessage: _getErrorMessage(
                  studyFortune, 
                  careerFortune, 
                  loveFortune,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getErrorMessage(
    AsyncValue studyFortune,
    AsyncValue careerFortune,
    AsyncValue loveFortune,
  ) {
    final errors = <String>[];
    
    if (studyFortune.hasError) {
      errors.add('學業運勢: ${studyFortune.error}');
    }
    if (careerFortune.hasError) {
      errors.add('事業運勢: ${careerFortune.error}');
    }
    if (loveFortune.hasError) {
      errors.add('愛情運勢: ${loveFortune.error}');
    }
    
    return errors.isEmpty ? null : errors.join('\n');
  }
} 