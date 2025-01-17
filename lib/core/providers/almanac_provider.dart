import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lunar_date.dart';
import '../repositories/almanac_repository.dart';

final almanacRepositoryProvider = Provider<AlmanacRepository>((ref) {
  return AlmanacRepository();
});

final currentLunarDateProvider = FutureProvider<LunarDate>((ref) async {
  final repository = ref.watch(almanacRepositoryProvider);
  final today = DateTime.now();
  return repository.getLunarDate(today);
});

final monthLunarDatesProvider = FutureProvider.family<List<LunarDate>, DateTime>((ref, date) async {
  final repository = ref.watch(almanacRepositoryProvider);
  return repository.getMonthLunarDates(date);
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now()); 