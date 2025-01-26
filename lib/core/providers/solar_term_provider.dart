import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/solar_term_service.dart';
import '../models/solar_term.dart';

/// 節氣服務提供者
final solarTermServiceProvider = Provider<SolarTermService>((ref) {
  return SolarTermService();
});

/// 下一個節氣提供者
final nextSolarTermProvider = FutureProvider<SolarTerm?>((ref) async {
  final service = ref.watch(solarTermServiceProvider);
  return service.getNextTerm(DateTime.now());
});

/// 未來節氣列表提供者
final upcomingSolarTermsProvider = FutureProvider<List<SolarTerm>>((ref) async {
  final service = ref.watch(solarTermServiceProvider);
  return service.getNextTerms(DateTime.now());
}); 