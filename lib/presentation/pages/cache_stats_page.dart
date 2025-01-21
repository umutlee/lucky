import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/cache_manager.dart';

class CacheStatsPage extends ConsumerStatefulWidget {
  const CacheStatsPage({super.key});

  @override
  ConsumerState<CacheStatsPage> createState() => _CacheStatsPageState();
}

class _CacheStatsPageState extends ConsumerState<CacheStatsPage> {
  bool _isLoading = false;

  Future<void> _clearCache(String type) async {
    setState(() => _isLoading = true);
    try {
      final cacheManager = ref.read(cacheManagerProvider);
      switch (type) {
        case 'clear_all':
          await cacheManager.clearAllCache();
          break;
        case 'clear_expired':
          await cacheManager.clearExpiredCache();
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('緩存已清理')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清理失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cacheManager = ref.watch(cacheManagerProvider);
    final stats = cacheManager.getCacheStats();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('緩存統計'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            PopupMenuButton<String>(
              onSelected: _clearCache,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: Text('清理所有緩存'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_expired',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('清理過期緩存'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSummaryCard(stats, theme),
            const SizedBox(height: 16),
            _buildDetailCard('內存緩存', stats['memory'], Icons.memory, theme),
            const SizedBox(height: 8),
            _buildDetailCard('黃曆緩存', stats['database']['almanac'], Icons.calendar_today, theme),
            const SizedBox(height: 8),
            _buildDetailCard('運勢緩存', stats['database']['fortune'], Icons.stars, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> stats, ThemeData theme) {
    final totalHits = stats['memory']['hits'] +
        stats['database']['almanac']['hits'] +
        stats['database']['fortune']['hits'];
    final totalMisses = stats['memory']['misses'] +
        stats['database']['almanac']['misses'] +
        stats['database']['fortune']['misses'];
    final hitRate = totalHits + totalMisses > 0
        ? (totalHits * 100 ~/ (totalHits + totalMisses))
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '緩存總覽',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  '總命中率',
                  '$hitRate%',
                  Icons.speed,
                  theme,
                ),
                _buildSummaryItem(
                  '命中次數',
                  totalHits.toString(),
                  Icons.check_circle_outline,
                  theme,
                ),
                _buildSummaryItem(
                  '未命中次數',
                  totalMisses.toString(),
                  Icons.cancel_outlined,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    String title,
    Map<String, dynamic> stats,
    IconData icon,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const Divider(),
            _buildStatRow('命中次數', stats['hits'].toString(), theme),
            _buildStatRow('未命中次數', stats['misses'].toString(), theme),
            _buildStatRow('命中率', '${stats['hitRate']}%', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
} 