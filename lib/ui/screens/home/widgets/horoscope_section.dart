import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/horoscope_provider.dart';
import '../../../../core/models/horoscope.dart';
import '../../../../core/utils/horoscope_image_helper.dart';
import '../../../widgets/loading_indicator.dart';

class HoroscopeSection extends ConsumerWidget {
  const HoroscopeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final horoscopeState = ref.watch(horoscopeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  onPressed: () {
                    // TODO: 導航到星座詳情頁
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
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      horoscopeState.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () {
                        ref.read(horoscopeProvider.notifier).refreshFortune();
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
                        HoroscopeImageHelper.getHoroscopeImagePath(horoscopeState.userHoroscope),
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            horoscopeState.userHoroscope.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            horoscopeState.fortuneDescription ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          if (horoscopeState.luckyElements != null) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: horoscopeState.luckyElements!.map((element) => Chip(
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
      ),
    );
  }
} 