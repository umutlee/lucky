import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scene.dart';
import '../../../core/services/fortune_score_service.dart';
import '../../widgets/fortune_chart.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';
import '../../../core/services/scene_service.dart';
import '../../widgets/error_view.dart';

/// 場景詳情頁面
class SceneDetailScreen extends ConsumerStatefulWidget {
  /// 創建場景詳情頁面
  const SceneDetailScreen({
    super.key,
    required this.scene,
  });

  /// 場景數據
  final Scene scene;

  @override
  ConsumerState<SceneDetailScreen> createState() => _SceneDetailScreenState();
}

class _SceneDetailScreenState extends ConsumerState<SceneDetailScreen> {
  late Future<Scene> _sceneFuture;

  @override
  void initState() {
    super.initState();
    _loadScene();
  }

  void _loadScene() {
    _sceneFuture = ref.read(sceneServiceProvider).getSceneById(widget.scene.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scene.name),
      ),
      body: FutureBuilder<Scene>(
        future: _sceneFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: '載入失敗',
              onRetry: () {
                setState(() {
                  _loadScene();
                });
              },
            );
          }

          final scene = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 場景圖片
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              scene.icon,
                              size: 96,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Image(
                          image: AssetImage(scene.imageUrl ?? 'assets/images/scenes/placeholder.jpg'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.colorScheme.errorContainer,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '圖片載入失敗',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 場景信息
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 場景名稱
                      Text(
                        scene.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),

                      // 場景描述
                      Text(
                        scene.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),

                      // 場景標籤
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in scene.tags)
                            Chip(
                              label: Text(tag),
                              backgroundColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 場景類型
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: const Text('類型'),
                        subtitle: Text(scene.type.displayName),
                      ),

                      // 場景狀態
                      if (scene.isLocked)
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('狀態'),
                          subtitle: Text(scene.unlockCondition ?? '未解鎖'),
                          trailing: TextButton(
                            onPressed: () {
                              // TODO: 實現解鎖功能
                            },
                            child: const Text('解鎖'),
                          ),
                        ),

                      // 場景統計
                      ListTile(
                        leading: const Icon(Icons.visibility),
                        title: const Text('瀏覽次數'),
                        subtitle: Text('${scene.viewCount} 次'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('使用次數'),
                        subtitle: Text('${scene.useCount} 次'),
                      ),
                      if (scene.lastViewedAt != null)
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('最後使用時間'),
                          subtitle: Text(
                            scene.lastViewedAt!.toLocal().toString(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 實現使用場景功能
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('使用場景'),
      ),
    );
  }
} 