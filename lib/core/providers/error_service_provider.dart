import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_service.dart';
import '../utils/logger.dart';

final errorServiceProvider = Provider<ErrorService>((ref) {
  final logger = Logger('ErrorService');
  return ErrorService(logger);
}); 