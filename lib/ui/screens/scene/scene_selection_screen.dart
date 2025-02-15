import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';
import '../../../core/providers/scene_provider.dart';
import '../../../core/models/scene.dart';
import '../../../core/services/scene_service.dart';
import 'scene_detail_screen.dart';

class SceneSelectionScreen extends ConsumerStatefulWidget {
  const SceneSelectionScreen({super.key});

  @override
  ConsumerState<SceneSelectionScreen> createState() => _SceneSelectionScreenState();
}

class _SceneSelectionScreenState extends ConsumerState<SceneSelectionScreen> {
  late Future<List<Scene>> _scenesFuture;
  late Future<List<Scene>> _recommendedScenesFuture;

  @override
  void initState() {
    super.initState();
    _loadScenes();
  }

  void _loadScenes() {
    final sceneService = ref.read(sceneServiceProvider);
    _scenesFuture = sceneService.getScenes();
    _recommendedScenesFuture = sceneService.getRecommendedScenes(
      date: DateTime.now(),
      userPreferences: null, // TODO: 從用戶設置獲取
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇場景'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _loadScenes()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _loadScenes()),
        child: CustomScrollView(
          slivers: [
            // 推薦場景部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '推薦場景',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Scene>>(
                      future: _recommendedScenesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingIndicator();
                        }
                        
                        if (snapshot.hasError) {
                          return ErrorView(
                            error: snapshot.error.toString(),
                            onRetry: () => setState(() => _loadScenes()),
                          );
                        }
                        
                        final recommendedScenes = snapshot.data ?? [];
                        if (recommendedScenes.isEmpty) {
                          return const Center(
                            child: Text('暫無推薦場景'),
                          );
                        }
                        
                        return SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendedScenes.length,
                            itemBuilder: (context, index) {
                              final scene = recommendedScenes[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _RecommendedSceneCard(
                                  scene: scene,
                                  onTap: () => _navigateToDetail(scene),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // 所有場景部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '所有場景',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // 場景網格
            FutureBuilder<List<Scene>>(
              future: _scenesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: LoadingIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: ErrorView(
                      error: snapshot.error.toString(),
                      onRetry: () => setState(() => _loadScenes()),
                    ),
                  );
                }
                
                final scenes = snapshot.data ?? [];
                if (scenes.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('暫無場景數據'),
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final scene = scenes[index];
                        return _SceneCard(
                          scene: scene,
                          onTap: () => _navigateToDetail(scene),
                        );
                      },
                      childCount: scenes.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Scene scene) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SceneDetailScreen(scene: scene),
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
              // 推薦標記
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '推薦',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback onTap;

  const _SceneCard({
    required this.scene,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scene.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scene.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
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