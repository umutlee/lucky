import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_fortune.dart';
import '../repositories/fortune_repository.dart';

final fortuneRepositoryProvider = Provider<FortuneRepository>((ref) {
  return FortuneRepository();
});

final dailyFortuneProvider = FutureProvider.family<DailyFortune, DateTime>((ref, date) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  return repository.getDailyFortune(date);
});

final monthFortunesProvider = FutureProvider.family<Map<DateTime, DailyFortune>, DateTime>((ref, date) async {
  final repository = ref.watch(fortuneRepositoryProvider);
  return repository.getMonthFortunes(date);
}); 