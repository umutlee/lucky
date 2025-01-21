import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/database_service.dart';
import '../services/cache_service.dart';
import '../repositories/fortune_repository.dart';
import '../repositories/almanac_repository.dart';
import '../interceptors/api_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final cacheService = ref.watch(cacheServiceProvider);
  
  dio.interceptors.addAll([
    ApiInterceptor(cacheService: cacheService),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
  ]);
  
  return dio;
});

final fortuneRepositoryProvider = Provider<FortuneRepository>((ref) {
  return FortuneRepository(
    ref.watch(dioProvider),
    ref.watch(databaseServiceProvider),
  );
});

final almanacRepositoryProvider = Provider<AlmanacRepository>((ref) {
  return AlmanacRepository(
    ref.watch(dioProvider),
    ref.watch(databaseServiceProvider),
  );
}); 