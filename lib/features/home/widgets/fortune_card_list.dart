import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune_display_config.dart';
import '../../../core/providers/fortune_config_provider.dart';
import 'fortune_card_wrapper.dart';

/// 運勢卡片列表
class FortuneCardList extends ConsumerWidget {
  final Map<String, Widget> fortuneCards;
  final ScrollController? scrollController;

  const FortuneCardList({
    super.key,
    required this.fortuneCards,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayConfig = ref.watch(fortuneDisplayConfigProvider);
    final expandedTypes = ref.watch(expandedFortuneTypesProvider);

    final visibleCards = displayConfig.visibleTypes
        .map((type) => MapEntry(type, fortuneCards[type]!))
        .toList();

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleCards.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final types = List<String>.from(displayConfig.visibleTypes);
        final type = types.removeAt(oldIndex);
        types.insert(newIndex, type);
        ref.read(fortuneDisplayConfigProvider.notifier).updateOrder(types);
      },
      itemBuilder: (context, index) {
        final type = visibleCards[index].key;
        final card = visibleCards[index].value;
        final isExpanded = expandedTypes.contains(type);

        return Padding(
          key: ValueKey(type),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FortuneCardWrapper(
            isExpanded: isExpanded,
            onTap: () => ref.read(expandedFortuneTypesProvider.notifier).toggle(type),
            child: card,
          ),
        );
      },
    );
  }
} 