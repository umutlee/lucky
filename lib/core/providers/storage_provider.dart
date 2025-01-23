import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';
import '../services/storage_service.dart';

/// StorageService Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return StorageService(prefsService);
}); 