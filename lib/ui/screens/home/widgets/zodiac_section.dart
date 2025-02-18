import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/zodiac_provider.dart';
import '../../../../core/models/zodiac.dart';
import '../../../../core/utils/zodiac_image_helper.dart';

class ZodiacSection extends ConsumerWidget {
  const ZodiacSection({super.key, this.isTest = false});

  final bool isTest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final zodiacState = ref.watch(zodiacNotifierProvider);

    return Card(
      child: zodiacState.when(
        data: (state) => state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text(state.errorMessage ?? '載入生肖運勢失敗'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(zodiacNotifierProvider.notifier).refreshFortune();
                          },
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                if (!isTest) ...[
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Image.asset(
                                      ZodiacImageHelper.getZodiacImagePath(state.userZodiac),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '生肖運勢',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Text(
                                        state.userZodiac.displayName,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    ref.read(zodiacNotifierProvider.notifier).refreshFortune();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        if (state.fortuneDescription != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            state.fortuneDescription!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        if (state.luckyElements.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.luckyElements
                                .map((element) => Chip(
                                      label: Text(element),
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      labelStyle: TextStyle(
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(zodiacNotifierProvider.notifier).refreshFortune();
                },
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 