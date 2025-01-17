import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'storage_provider.dart';

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
}); 