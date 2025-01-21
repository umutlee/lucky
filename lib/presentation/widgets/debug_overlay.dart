import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/cache_manager.dart';
import 'package:go_router/go_router.dart';

class DebugOverlay extends ConsumerWidget {
  const DebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      bottom: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/cache-stats'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.memory,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Consumer(
                  builder: (context, ref, _) {
                    final stats = ref.watch(cacheManagerProvider).getCacheStats();
                    final hitRate = stats['memory']['hitRate'];
                    return Text(
                      '緩存命中率: $hitRate%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 