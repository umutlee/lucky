import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune.dart';
import '../../../core/services/fortune_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../widgets/fortune_history_card.dart';

class FortuneHistoryScreen extends ConsumerStatefulWidget {
  final String zodiac;
  final String constellation;

  const FortuneHistoryScreen({
    Key? key,
    required this.zodiac,
    required this.constellation,
  }) : super(key: key);

  @override
  ConsumerState<FortuneHistoryScreen> createState() => _FortuneHistoryScreenState();
}

class _FortuneHistoryScreenState extends ConsumerState<FortuneHistoryScreen> {
  late Future<List<Fortune>> _historyFuture;
  int _limit = 7;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final fortuneService = ref.read(fortuneServiceProvider);
    _historyFuture = fortuneService.getFortuneHistory(
      widget.zodiac,
      widget.constellation,
      limit: _limit,
    );
  }

  void _loadMore() {
    setState(() {
      _limit += 7;
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('運勢歷史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 實現篩選功能
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Fortune>>(
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

          final fortunes = snapshot.data ?? [];
          if (fortunes.isEmpty) {
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
              itemCount: fortunes.length + 1,
              itemBuilder: (context, index) {
                if (index == fortunes.length) {
                  return _buildLoadMoreButton();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FortuneHistoryCard(fortune: fortunes[index]),
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