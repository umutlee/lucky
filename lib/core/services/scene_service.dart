import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene.dart';

final sceneServiceProvider = Provider<SceneService>((ref) => SceneService());

class SceneService {
  Future<List<Scene>> getScenes() async {
    // TODO: 從API獲取場景數據
    // 目前返回模擬數據
    return [
      const Scene(
        id: 'study',
        name: '學習運勢',
        description: '考試、學習、升學運勢分析',
        imageAsset: 'assets/images/scenes/study.jpg',
        type: 'study',
        parameters: {'difficulty': 'medium'},
      ),
      const Scene(
        id: 'career',
        name: '職場運勢',
        description: '工作、升遷、創業運勢分析',
        imageAsset: 'assets/images/scenes/career.jpg',
        type: 'career',
        parameters: {'industry': 'general'},
      ),
      const Scene(
        id: 'love',
        name: '感情運勢',
        description: '戀愛、婚姻、人際關係分析',
        imageAsset: 'assets/images/scenes/love.jpg',
        type: 'love',
        parameters: {'status': 'single'},
      ),
      const Scene(
        id: 'wealth',
        name: '財運分析',
        description: '投資、理財、收入運勢分析',
        imageAsset: 'assets/images/scenes/wealth.jpg',
        type: 'wealth',
        parameters: {'risk_level': 'medium'},
      ),
      const Scene(
        id: 'health',
        name: '健康運勢',
        description: '身體、心理健康運勢分析',
        imageAsset: 'assets/images/scenes/health.jpg',
        type: 'health',
        parameters: {'focus': 'general'},
      ),
      const Scene(
        id: 'travel',
        name: '旅行運勢',
        description: '出行、旅遊、探險運勢分析',
        imageAsset: 'assets/images/scenes/travel.jpg',
        type: 'travel',
        parameters: {'duration': 'short'},
      ),
    ];
  }

  Future<Scene> getSceneById(String id) async {
    final scenes = await getScenes();
    return scenes.firstWhere((scene) => scene.id == id);
  }
} 