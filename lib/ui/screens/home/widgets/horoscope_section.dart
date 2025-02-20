import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/horoscope_provider.dart';
import '../../../../core/models/horoscope.dart';
import '../../../../core/utils/horoscope_image_helper.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../../core/providers/navigation_service_provider.dart';
import '../../../../core/providers/error_service_provider.dart';

class HoroscopeSection extends ConsumerWidget {
  const HoroscopeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final horoscopeState = ref.watch(horoscopeProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '星座運勢',
                style: theme.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final result = await ref.read(navigationServiceProvider).navigateToHoroscopeDetail(horoscopeState.userHoroscope);
                    if (!result) {
                      final error = await ref.read(errorServiceProvider).handleError(
                        Exception('導航失敗'),
                        StackTrace.current,
                      );
                      ref.read(horoscopeProvider.notifier).setError(error);
                    }
                  } catch (e, stackTrace) {
                    final error = await ref.read(errorServiceProvider).handleError(e, stackTrace);
                    ref.read(horoscopeProvider.notifier).setError(error);
                  }
                },
                child: const Text('查看更多'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (horoscopeState.isLoading)
            const Center(
              child: LoadingIndicator(
                size: 32.0,
                message: '載入星座運勢中...',
              ),
            )
          else if (horoscopeState.error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(horoscopeState.error!.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(horoscopeProvider.notifier).retry();
                    },
                    child: const Text('重試'),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      HoroscopeImageHelper.getImagePath(horoscopeState.userHoroscope),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horoscopeState.userHoroscope.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          horoscopeState.fortuneDescription?.isNotEmpty == true
                              ? horoscopeState.fortuneDescription!
                              : '暫無運勢數據',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        if (horoscopeState.luckyElements.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: horoscopeState.luckyElements.map((element) => Chip(
                              label: Text(element),
                              backgroundColor: theme.colorScheme.surface,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 