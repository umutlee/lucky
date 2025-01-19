import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune.dart';
import '../../../core/services/fortune_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../widgets/fortune_card.dart';
import '../widgets/recommendation_list.dart';
import '../../../core/services/share_service.dart';
import '../../../features/fortune/screens/fortune_history_screen.dart';

class FortuneDetailScreen extends ConsumerStatefulWidget {
  final String date;
  final String zodiac;
  final String constellation;

  const FortuneDetailScreen({
    Key? key,
    required this.date,
    required this.zodiac,
    required this.constellation,
  }) : super(key: key);

  @override
  ConsumerState<FortuneDetailScreen> createState() => _FortuneDetailScreenState();
}

class _FortuneDetailScreenState extends ConsumerState<FortuneDetailScreen> {
  late Future<Fortune?> _fortuneFuture;

  @override
  void initState() {
    super.initState();
    _loadFortune();
  }

  void _loadFortune() {
    final fortuneService = ref.read(fortuneServiceProvider);
    _fortuneFuture = fortuneService.getDailyFortune(
      widget.date,
      widget.zodiac,
      widget.constellation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日運勢'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadFortune();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Fortune?>(
        future: _fortuneFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error.toString(),
              onRetry: _loadFortune,
            );
          }

          final fortune = snapshot.data;
          if (fortune == null) {
            return const ErrorView(
              error: '無法獲取運勢信息',
              onRetry: null,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FortuneCard(fortune: fortune),
                const SizedBox(height: 16.0),
                RecommendationList(recommendations: fortune.recommendations),
                const SizedBox(height: 24.0),
                _buildZodiacAffinitySection(fortune.zodiacAffinity),
                const SizedBox(height: 16.0),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildZodiacAffinitySection(Map<String, int> affinities) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生肖相性',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: affinities.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}%'),
                  backgroundColor: _getAffinityColor(entry.value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAffinityColor(int value) {
    if (value >= 80) return Colors.green.shade100;
    if (value >= 60) return Colors.blue.shade100;
    if (value >= 40) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.share),
          label: const Text('分享'),
          onPressed: () async {
            final fortune = await _fortuneFuture;
            if (fortune != null) {
              final shareService = ref.read(shareServiceProvider);
              await shareService.shareFortune(fortune);
            }
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: const Text('查看歷史'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FortuneHistoryScreen(
                  zodiac: widget.zodiac,
                  constellation: widget.constellation,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 