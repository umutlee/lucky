import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/models/fortune.dart';
import '../widgets/fortune_filter.dart';
import '../widgets/fortune_list.dart';

class FortuneScreen extends ConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortunes = ref.watch(filteredFortunesProvider([])); // TODO: 從數據源獲取運勢列表

    return Scaffold(
      appBar: AppBar(
        title: const Text('運勢預測'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: FortuneFilter(),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 推薦運勢卡片
          if (fortunes.isNotEmpty) ...[
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日推薦',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '最適合的活動：${fortunes.first.suitableActivities.join('、')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '吉利方位：${fortunes.first.luckyDirections.join('、')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // 運勢列表
          Expanded(
            child: FortuneList(fortunes: fortunes),
          ),
        ],
      ),
    );
  }
} 