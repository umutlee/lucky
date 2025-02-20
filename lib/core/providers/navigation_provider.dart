import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/navigation_service.dart';

part 'navigation_provider.g.dart';

@riverpod
NavigationService navigationService(NavigationServiceRef ref) {
  return NavigationService();
} 