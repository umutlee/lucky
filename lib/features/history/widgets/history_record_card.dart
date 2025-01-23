import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/history_record.dart';
import '../../../core/services/history_service.dart';

class HistoryRecordCard extends ConsumerWidget {
  final HistoryRecord record;

  const HistoryRecordCard({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          // TODO: 實現點擊查看詳情
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.result,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _formatTimestamp(record.timestamp),
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  record.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: record.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    final isFortuneType = record.type == 'fortune';
    return Icon(
      isFortuneType ? Icons.star : Icons.explore,
      size: 32.0,
      color: isFortuneType ? Colors.amber : Colors.blue,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}/${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute}';
  }

  Future<void> _toggleFavorite(WidgetRef ref) async {
    final historyService = ref.read(historyServiceProvider);
    await historyService.toggleFavorite(record.id);
  }
} 