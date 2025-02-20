import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/zodiac.dart';
import '../../../core/providers/zodiac_provider.dart';
import '../../../core/models/app_error.dart';

class ZodiacSection extends ConsumerWidget {
  const ZodiacSection({Key? key}) : super(key: key);

  String _getZodiacImagePath(Zodiac zodiac) {
    return 'assets/images/zodiac/Chinese 12 Zodiacs - ${zodiac.name.capitalize()}.jpg';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zodiacState = ref.watch(zodiacNotifierProvider);

    return zodiacState.when(
      data: (state) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '生肖運勢',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              if (state.hasError && state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                )
              else if (state.fortuneDescription?.isEmpty ?? true)
                const Text('暫無運勢')
              else
                Column(
                  children: [
                    Image.asset(
                      _getZodiacImagePath(state.userZodiac),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      state.fortuneDescription!.length > 100
                          ? '${state.fortuneDescription!.substring(0, 100)}...'
                          : state.fortuneDescription!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (state.luckyElements.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        children: state.luckyElements
                            .map((element) => Chip(
                                  label: Text(element),
                                  backgroundColor: Colors.amber[100],
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(zodiacNotifierProvider.notifier).refreshFortune();
                    },
                    child: const Text('重試'),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error is AppError ? error.message : error.toString(),
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                ref.read(zodiacNotifierProvider.notifier).refreshFortune();
              },
              child: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
} 