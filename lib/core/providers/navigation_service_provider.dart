import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
}); 