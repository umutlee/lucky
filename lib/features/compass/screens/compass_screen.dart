import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/compass_provider.dart';
import '../widgets/compass_display.dart';
import '../widgets/direction_info_card.dart';
import '../widgets/lucky_direction_indicator.dart';

class CompassScreen extends ConsumerStatefulWidget {
  const CompassScreen({super.key});

  @override
  ConsumerState<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends ConsumerState<CompassScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化羅盤服務
    ref.read(compassProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compassState = ref.watch(compassProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('方位指南'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDirectionGuide(context),
          ),
        ],
      ),
      body: compassState.when(
        data: (direction) => Column(
          children: [
            // 羅盤顯示
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CompassDisplay(
                  direction: direction,
                  luckyDirections: const ['東', '南'],
                ),
              ),
            ),
            
            // 方位信息卡片
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DirectionInfoCard(
                      direction: direction,
                    ),
                    const SizedBox(height: 16),
                    LuckyDirectionIndicator(
                      currentDirection: direction,
                      luckyDirections: const ['東', '南'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.compass_calibration,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '無法獲取方位數據',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(compassProvider.notifier).initialize();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重試'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDirectionGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('方位說明'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDirectionGuideItem('東（E）', '代表生發、成長'),
              _buildDirectionGuideItem('南（S）', '代表旺盛、熱情'),
              _buildDirectionGuideItem('西（W）', '代表收斂、沉穩'),
              _buildDirectionGuideItem('北（N）', '代表儲藏、蓄勢'),
              const Divider(),
              const Text(
                '提示：請保持手機水平以獲得準確的方位數據',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionGuideItem(String direction, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            direction,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
} 