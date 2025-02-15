import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scene.dart';
import '../../../core/services/scene_service.dart';

final sceneProvider = FutureProvider.family<Scene, String>((ref, id) {
  final sceneService = ref.watch(sceneServiceProvider);
  return sceneService.getSceneById(id);
});

class SceneDetailsScreen extends ConsumerWidget {
  final String sceneId;

  const SceneDetailsScreen({
    super.key,
    required this.sceneId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sceneAsync = ref.watch(sceneProvider(sceneId));

    return Scaffold(
      body: sceneAsync.when(
        data: (scene) => _SceneDetailsView(scene: scene),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('加載失敗: $error'),
        ),
      ),
    );
  }
}

class _SceneDetailsView extends ConsumerWidget {
  final Scene scene;

  const _SceneDetailsView({required this.scene});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;

    return Stack(
      children: [
        // 背景圖片
        Positioned.fill(
          child: Image.asset(
            scene.imagePath,
            fit: BoxFit.cover,
          ),
        ),

        // 漸變遮罩
        Positioned.fill(
          child: Container(
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
        ),

        // 返回按鈕
        Positioned(
          top: padding.top,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // 場景信息
        Positioned(
          left: 16,
          right: 16,
          bottom: padding.bottom + 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                scene.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scene.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              if (scene.isLocked)
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(sceneServiceProvider)
                          .unlockScene(scene.id);
                      ref.invalidate(sceneProvider(scene.id));
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('解鎖失敗: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: Text(scene.unlockCondition ?? '解鎖'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(sceneServiceProvider)
                          .incrementViewCount(scene.id);
                      // TODO: 實現占卜邏輯
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('操作失敗: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('開始占卜'),
                ),
            ],
          ),
        ),
      ],
    );
  }
} 