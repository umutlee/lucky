import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

/// 存儲服務提供者
final storageProvider = Provider<StorageService>((ref) {
  final logger = Logger('StorageService');
  return StorageService(logger);
}); 