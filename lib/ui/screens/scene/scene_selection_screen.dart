import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';
import '../../../core/providers/scene_provider.dart';
import '../../../core/models/scene.dart';

class SceneSelectionScreen extends ConsumerWidget {
  const SceneSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scenes = ref.watch(sceneProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇場景'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: 顯示歷史記錄
            },
          ),
        ],
      ),
      body: ErrorBoundary(
        child: scenes.when(
          data: (sceneList) => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: sceneList.length,
            itemBuilder: (context, index) {
              final scene = sceneList[index];
              return SceneCard(scene: scene);
            },
          ),
          loading: () => const LoadingIndicator(),
          error: (error, stack) => Center(
            child: Text('載入失敗: $error', style: theme.textTheme.bodyLarge),
          ),
        ),
      ),
    );
  }
}

class SceneCard extends StatelessWidget {
  final Scene scene;

  const SceneCard({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/scene/detail',
            arguments: scene,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  image: DecorationImage(
                    image: AssetImage(scene.imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.surface.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scene.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 