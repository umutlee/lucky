import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune.dart';
import '../../../core/providers/fortune_provider.dart';
import '../widgets/fortune_prediction_card.dart';
import '../widgets/fortune_date_picker.dart';
import '../widgets/fortune_type_selector.dart';

class FortunePredictionScreen extends ConsumerStatefulWidget {
  const FortunePredictionScreen({super.key});

  @override
  ConsumerState<FortunePredictionScreen> createState() => _FortunePredictionScreenState();
}

class _FortunePredictionScreenState extends ConsumerState<FortunePredictionScreen> {
  DateTime _selectedDate = DateTime.now();
  FortuneType _selectedType = FortuneType.general;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('運勢預測'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: 導航到歷史記錄頁面
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 日期選擇器
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FortuneDatePicker(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
          
          // 運勢類型選擇器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FortuneTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
          ),
          
          const Divider(height: 32),
          
          // 運勢預測卡片
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final fortune = ref.watch(
                  fortuneProvider(_selectedDate, _selectedType),
                );
                
                return fortune.when(
                  data: (data) => FortunePredictionCard(
                    fortune: data,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '無法獲取運勢預測',
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
                            ref.invalidate(fortuneProvider(_selectedDate, _selectedType));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('重試'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 