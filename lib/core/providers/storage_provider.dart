import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';
import '../services/storage_service.dart';

/// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('需要在 main.dart 中覆蓋此 provider');
});

/// StorageService Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
}); 