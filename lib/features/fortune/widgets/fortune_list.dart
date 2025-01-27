import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/providers/fortune_list_provider.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'fortune_card.dart';

class FortuneList extends ConsumerStatefulWidget {
  const FortuneList({super.key});

  @override
  ConsumerState<FortuneList> createState() => _FortuneListState();
}

class _FortuneListState extends ConsumerState<FortuneList> {
  final _logger = Logger('FortuneList');
  final _scrollController = ScrollController();
  final _cacheService = CacheService();
  final _itemExtent = 160.0; // 增加卡片高度

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      ref.read(fortuneListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fortunesAsync = ref.watch(fortuneListProvider);
    
    return fortunesAsync.when(
      data: (fortunes) {
        final filteredFortunes = ref.watch(filteredFortunesProvider(fortunes));
        return _buildList(filteredFortunes);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '載入失敗',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(fortuneListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Fortune> fortunes) {
    if (fortunes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '沒有符合條件的運勢',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      itemCount: fortunes.length,
      itemBuilder: (context, index) {
        final fortune = fortunes[index];
        return _buildListItem(fortune, index);
      },
    );
  }

  Widget _buildListItem(Fortune fortune, int index) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final itemPosition = index * _itemExtent;
        final difference = _scrollController.offset - itemPosition;
        final percent = 1 - (difference / (_itemExtent / 2)).clamp(0.0, 1.0);

        return Opacity(
          opacity: percent,
          child: Transform.scale(
            scale: 0.8 + (0.2 * percent),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FortuneCard(fortune: fortune),
      ),
    );
  }

  void _onItemTap(Fortune fortune) {
    try {
      Navigator.pushNamed(
        context,
        '/fortune-detail',
        arguments: fortune,
      );
    } catch (e) {
      _logger.error('導航到詳情頁面失敗', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('打開詳情失敗'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
} 