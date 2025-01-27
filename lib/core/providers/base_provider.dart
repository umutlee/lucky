import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_service.dart';

mixin ErrorHandlingState {
  AppError? error;
  bool get hasError => error != null;
}

abstract class BaseStateNotifier<T extends ErrorHandlingState>
    extends StateNotifier<T> {
  final ErrorService _errorService;

  BaseStateNotifier(this._errorService, T initialState) : super(initialState);

  Future<void> handleError(
    Object error,
    StackTrace stackTrace,
    void Function(AppError appError) onError,
  ) async {
    final appError = _errorService.handleError(error, stackTrace);
    onError(appError);
  }

  // 用於處理異步操作的輔助方法
  Future<void> handleAsync(
    Future<void> Function() operation, {
    void Function()? onStart,
    void Function()? onSuccess,
    void Function(AppError error)? onError,
  }) async {
    try {
      onStart?.call();
      await operation();
      onSuccess?.call();
    } catch (error, stackTrace) {
      await handleError(
        error,
        stackTrace,
        onError ?? (_) {},
      );
    }
  }
}

// 用於需要加載狀態的 Provider
mixin LoadingState on ErrorHandlingState {
  bool isLoading = false;
}

// 用於需要刷新功能的 Provider
mixin RefreshableState on ErrorHandlingState {
  DateTime? lastRefreshed;
}

// 用於需要分頁功能的 Provider
mixin PaginationState on ErrorHandlingState {
  int currentPage = 1;
  bool hasMorePages = true;
  bool isLoadingMore = false;
} 