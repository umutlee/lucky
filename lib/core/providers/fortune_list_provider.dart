import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../repositories/fortune_repository.dart';

final fortuneListProvider = StateNotifierProvider<FortuneListNotifier, AsyncValue<List<Fortune>>>((ref) {
  return FortuneListNotifier(ref.watch(fortuneRepositoryProvider));
});

class FortuneListNotifier extends StateNotifier<AsyncValue<List<Fortune>>> {
  final FortuneRepository _repository;
  int _page = 1;
  bool _hasMore = true;
  static const _pageSize = 20;

  FortuneListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      final fortunes = await _repository.getFortunes(page: 1, pageSize: _pageSize);
      _page = 1;
      _hasMore = fortunes.length >= _pageSize;
      state = AsyncValue.data(fortunes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    try {
      final currentFortunes = state.value ?? [];
      final newFortunes = await _repository.getFortunes(
        page: _page + 1,
        pageSize: _pageSize,
      );

      _page++;
      _hasMore = newFortunes.length >= _pageSize;
      state = AsyncValue.data([...currentFortunes, ...newFortunes]);
    } catch (e, stack) {
      // 加載更多失敗時不更新狀態，只顯示錯誤提示
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await loadInitial();
  }
} 