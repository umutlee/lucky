import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/history_record.dart';
import '../../../core/services/history_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../widgets/history_record_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late Future<List<HistoryRecord>> _historyFuture;
  int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final historyService = ref.read(historyServiceProvider);
    _historyFuture = historyService.getRecords(limit: _limit);
  }

  void _loadMore() {
    setState(() {
      _limit += 10;
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歷史記錄'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 實現篩選功能
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: '加載歷史記錄中...');
          }

          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error.toString(),
              onRetry: _loadHistory,
            );
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Text(
                '暫無歷史記錄',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadHistory();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: records.length + 1,
              itemBuilder: (context, index) {
                if (index == records.length) {
                  return _buildLoadMoreButton();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: HistoryRecordCard(record: records[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: _loadMore,
          child: const Text('加載更多'),
        ),
      ),
    );
  }
} 