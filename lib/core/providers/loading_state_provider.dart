import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingState {
  final bool isLoading;
  final String? message;
  final double? progress;

  const LoadingState({
    this.isLoading = false,
    this.message,
    this.progress,
  });

  LoadingState copyWith({
    bool? isLoading,
    String? message,
    double? progress,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      progress: progress ?? this.progress,
    );
  }
}

class LoadingStateNotifier extends StateNotifier<LoadingState> {
  LoadingStateNotifier() : super(const LoadingState());

  void startLoading({String? message, double? progress}) {
    state = LoadingState(
      isLoading: true,
      message: message,
      progress: progress,
    );
  }

  void updateProgress(double progress, {String? message}) {
    if (state.isLoading) {
      state = state.copyWith(
        progress: progress,
        message: message ?? state.message,
      );
    }
  }

  void updateMessage(String message) {
    if (state.isLoading) {
      state = state.copyWith(message: message);
    }
  }

  void stopLoading() {
    state = const LoadingState(isLoading: false);
  }
}

final loadingStateProvider = StateNotifierProvider<LoadingStateNotifier, LoadingState>(
  (ref) => LoadingStateNotifier(),
); 