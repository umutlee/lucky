import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scene.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/scene_service.dart';

final scenesProvider = FutureProvider<List<Scene>>((ref) {
  final sceneService = ref.watch(sceneServiceProvider);
  return sceneService.getScenes();
});

class SceneSelectionScreen extends ConsumerWidget {
  const SceneSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenesAsync = ref.watch(scenesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇場景'),
      ),
      body: scenesAsync.when(
        data: (scenes) {
          if (scenes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('暫無可用場景'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];
              return _SceneCard(scene: scene);
            },
          );
        },
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

class _SceneCard extends StatelessWidget {
  final Scene scene;

  const _SceneCard({required this.scene});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.sceneDetails,
            arguments: {'sceneId': scene.id},
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              scene.imagePath,
              fit: BoxFit.cover,
            ),
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
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (scene.isLocked) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scene.unlockCondition ?? '未解鎖',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 