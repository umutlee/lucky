import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lunar_date.dart';
import '../models/api_response.dart';
import 'api_provider.dart';

/// 農曆日期 Provider
class AlmanacNotifier extends StateNotifier<AsyncValue<Map<DateTime, LunarDate>>> {
  final ApiClient _apiClient;

  AlmanacNotifier(this._apiClient) : super(const AsyncValue.loading());

  // 獲取當月農曆日期
  Future<void> fetchMonthLunarDates(DateTime date) async {
    state = const AsyncValue.loading();

    try {
      final Map<DateTime, LunarDate> monthDates = {};
      final firstDay = DateTime(date.year, date.month, 1);
      final lastDay = DateTime(date.year, date.month + 1, 0);

      final results = await Future.wait(
        List.generate(
          lastDay.day,
          (index) => _apiClient.getLunarDate(
            firstDay.add(Duration(days: index)),
          ),
        ),
      );

      for (var i = 0; i < results.length; i++) {
        final currentDate = firstDay.add(Duration(days: i));
        if (results[i].isSuccess && results[i].data != null) {
          monthDates[currentDate] = results[i].data!;
        }
      }

      state = AsyncValue.data(monthDates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 刷新農曆數據
  Future<void> refresh() async {
    await fetchMonthLunarDates(DateTime.now());
  }
}

/// 農曆數據 Provider
final almanacProvider = StateNotifierProvider<AlmanacNotifier, AsyncValue<Map<DateTime, LunarDate>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AlmanacNotifier(apiClient);
});

/// 當前農曆日期 Provider
final currentLunarDateProvider = Provider<AsyncValue<LunarDate?>>((ref) {
  final almanac = ref.watch(almanacProvider);
  final today = DateTime.now();
  return almanac.whenData((data) => data[DateTime(today.year, today.month, today.day)]);
});

final monthLunarDatesProvider = FutureProvider.family<List<LunarDate>, DateTime>((ref, date) async {
  final repository = ref.watch(almanacRepositoryProvider);
  return repository.getMonthLunarDates(date);
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now()); 