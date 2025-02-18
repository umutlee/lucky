import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/app_error.dart';

part 'base_provider.freezed.dart';
part 'base_provider.g.dart';

@freezed
class BaseState with _$BaseState {
  const factory BaseState({
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
    AppError? error,
  }) = _BaseState;

  factory BaseState.fromJson(Map<String, dynamic> json) =>
      _$BaseStateFromJson(json);
}

mixin ErrorHandlingState {
  AppError? get error;
  bool get hasError => error != null;
}

mixin LoadingState {
  bool isLoading = false;
}

mixin RefreshableState {
  DateTime? lastRefreshed;
}

mixin PaginationState {
  int currentPage = 1;
  bool hasMorePages = true;
  bool isLoadingMore = false;
}

abstract class BaseStateNotifier<T extends BaseState> extends StateNotifier<T> {
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