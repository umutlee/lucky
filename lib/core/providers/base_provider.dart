import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_service.dart';
import '../models/app_error.dart';

abstract class BaseState {
  bool get isLoading;
  bool get hasError;
  String? get errorMessage;
  AppError? get error;
}

mixin ErrorHandlingState {
  AppError? get error;
  bool get hasError => error != null;
  String? get errorMessage => error?.userMessage;
}

mixin LoadingState {
  bool get isLoading;
}

mixin RefreshableState {
  DateTime? get lastRefreshed;
}

mixin PaginationState {
  int get currentPage;
  bool get hasMorePages;
  bool get isLoadingMore;
}

abstract class BaseStateNotifier<T extends BaseState> extends StateNotifier<T> {
  final ErrorService _errorService;

  BaseStateNotifier(this._errorService, T initialState) : super(initialState);

  Future<void> handleError(
    Object error,
    StackTrace stackTrace,
    void Function(AppError appError) onError,
  ) async {
    final appError = await _errorService.handleError(error, stackTrace);
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