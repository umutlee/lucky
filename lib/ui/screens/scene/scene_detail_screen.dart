import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scene.dart';
import '../../../core/services/fortune_score_service.dart';
import '../../widgets/fortune_chart.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';
import '../../../core/services/scene_service.dart';
import '../../widgets/error_view.dart';

class SceneDetailScreen extends ConsumerStatefulWidget {
  final Scene scene;

  const SceneDetailScreen({
    super.key,
    required this.scene,
  });

  @override
  ConsumerState<SceneDetailScreen> createState() => _SceneDetailScreenState();
}

class _SceneDetailScreenState extends ConsumerState<SceneDetailScreen> {
  late Future<List<Scene>> _recommendedScenesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecommendedScenes();
  }

  void _loadRecommendedScenes() {
    final sceneService = ref.read(sceneServiceProvider);
    _recommendedScenesFuture = sceneService.getRecommendedScenes(
      date: DateTime.now(),
      userPreferences: null, // TODO: 從用戶設置獲取
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortuneScore = ref.watch(
      fortuneScoreProvider(
        type: widget.scene.fortuneType,
        date: DateTime.now(),
      ),
    );

    return Scaffold(
      body: ErrorBoundary(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, theme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDescription(theme),
                    const SizedBox(height: 24),
                    fortuneScore.when(
                      data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FortuneChart(
                            factors: data.factors,
                            overallScore: data.score,
                            type: widget.scene.fortuneType,
                          ),
                          const SizedBox(height: 24),
                          _buildSuggestions(theme, data.suggestions),
                          const SizedBox(height: 24),
                          _buildLuckyTimes(theme),
                        ],
                      ),
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(
                          '載入失敗: $error',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '相關推薦',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: FutureBuilder<List<Scene>>(
                        future: _recommendedScenesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LoadingIndicator();
                          }

                          if (snapshot.hasError) {
                            return ErrorView(
                              error: snapshot.error.toString(),
                              onRetry: () => setState(() => _loadRecommendedScenes()),
                            );
                          }

                          final scenes = snapshot.data ?? [];
                          if (scenes.isEmpty) {
                            return const Center(
                              child: Text('暫無相關推薦'),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: scenes.length,
                            itemBuilder: (context, index) {
                              final scene = scenes[index];
                              if (scene.id == widget.scene.id) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _RecommendedSceneCard(
                                  scene: scene,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SceneDetailScreen(
                                          scene: scene,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 實現分享功能
        },
        icon: const Icon(Icons.share),
        label: const Text('分享運勢'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar.large(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Hero(
          tag: 'scene_${widget.scene.id}_title',
          child: Text(
            widget.scene.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        background: Hero(
          tag: 'scene_${widget.scene.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: Icon(
                    widget.scene.icon,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '場景說明',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.scene.description,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme, List<String> suggestions) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '運勢建議',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(suggestion),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyTimes(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '吉時提示',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                '寅時 (3-5點)',
                '卯時 (5-7點)',
                '辰時 (7-9點)',
              ].map((time) => Chip(
                label: Text(time),
                avatar: const Icon(Icons.star, size: 16),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedSceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback onTap;

  const _RecommendedSceneCard({
    required this.scene,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 背景圖片
              Image.asset(
                scene.imageAsset,
                fit: BoxFit.cover,
              ),
              // 漸變遮罩
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // 場景信息
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scene.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scene.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 