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
      body: const Column(
        children: [
          // 運勢列表
          Expanded(
            child: FortuneList(),
          ),
        ],
      ),
    );
  }
} 