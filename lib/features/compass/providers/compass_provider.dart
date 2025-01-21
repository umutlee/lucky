import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../core/utils/logger.dart';

final compassProvider = StateNotifierProvider<CompassNotifier, AsyncValue<double>>(
  (ref) => CompassNotifier(),
);

class CompassNotifier extends StateNotifier<AsyncValue<double>> {
  StreamSubscription<CompassEvent>? _subscription;
  final _logger = AppLogger();

  CompassNotifier() : super(const AsyncValue.loading());

  Future<void> initialize() async {
    try {
      if (!await FlutterCompass.events.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('無法獲取方位數據'),
      )) {
        throw Exception('設備不支持羅盤功能');
      }

      _subscription = FlutterCompass.events.listen(
        (event) {
          if (event.heading != null) {
            state = AsyncValue.data(event.heading!);
          }
        },
        onError: (error) {
          _logger.e('羅盤數據獲取失敗', error);
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (error, stackTrace) {
      _logger.e('羅盤初始化失敗', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
} 