import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/providers/fortune_list_provider.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/logger.dart';

class FortuneList extends ConsumerStatefulWidget {
  const FortuneList({super.key});

  @override
  ConsumerState<FortuneList> createState() => _FortuneListState();
}

class _FortuneListState extends ConsumerState<FortuneList> {
  final _logger = Logger('FortuneList');
  final _scrollController = ScrollController();
  final _cacheService = CacheService();
  final _itemExtent = 100.0; // 固定每個項目的高度

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
      // 觸發加載更多
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('載入失敗: $error'),
      ),
    );
  }

  Widget _buildList(List<Fortune> fortunes) {
    if (fortunes.isEmpty) {
      return const Center(
        child: Text('沒有符合條件的運勢'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(fortuneListProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        // 使用 ListView.builder 的性能優化選項
        itemExtent: _itemExtent, // 固定高度
        cacheExtent: _itemExtent * 10, // 預加載 10 個項目
        itemCount: fortunes.length,
        itemBuilder: (context, index) {
          // 使用緩存服務緩存列表項
          final cacheKey = 'fortune_item_$index';
          var widget = _cacheService.get<Widget>(cacheKey);
          
          if (widget == null) {
            widget = _buildListItem(fortunes[index]);
            _cacheService.put(cacheKey, widget);
          }

          return widget;
        },
      ),
    );
  }

  Widget _buildListItem(Fortune fortune) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: ListTile(
          onTap: () => _onItemTap(fortune),
          title: Text(
            fortune.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '推薦活動: ${fortune.recommendations.join(", ")}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fortune.score.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                fortune.isLuckyDay ? '吉日' : '普通',
                style: TextStyle(
                  color: fortune.isLuckyDay
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
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
        const SnackBar(
          content: Text('打開詳情失敗'),
        ),
      );
    }
  }
} 