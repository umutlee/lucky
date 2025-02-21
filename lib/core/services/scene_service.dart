import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene.dart';
import '../models/fortune_type.dart';
import '../utils/logger.dart';

/// 場景服務提供者
final sceneServiceProvider = Provider<SceneService>((ref) {
  return SceneService();
});

/// 場景服務
class SceneService {
  final List<Scene> _scenes = [
    Scene(
      id: 'scene1',
      title: '晨光祈福',
      description: '在晨光中感受新的一天的祝福',
      icon: Icons.wb_sunny,
      type: SceneType.health,
      imageUrl: 'assets/images/scenes/scene1.jpg',
      tags: ['晨間', '祈福', '新的開始'],
    ),
    Scene(
      id: 'scene2',
      title: '書房靈感',
      description: '在書房中尋找學習的靈感',
      icon: Icons.book,
      type: SceneType.study,
      imageUrl: 'assets/images/scenes/scene2.jpg',
      tags: ['學習', '靈感', '專注'],
    ),
    Scene(
      id: 'scene3',
      title: '職場運勢',
      description: '在辦公室中探索事業機遇',
      icon: Icons.work,
      type: SceneType.career,
      imageUrl: 'assets/images/scenes/scene3.jpg',
      tags: ['事業', '機遇', '成長'],
    ),
    Scene(
      id: 'scene4',
      title: '月下情緣',
      description: '在月光下感受愛情的美好',
      icon: Icons.favorite,
      type: SceneType.love,
      imageUrl: 'assets/images/scenes/scene4.jpg',
      tags: ['愛情', '浪漫', '月光'],
    ),
  ];

  final Logger _logger = Logger('SceneService');

  // 場景緩存
  List<Scene>? _cachedScenes;
  DateTime? _lastCacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  final int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;

  /// 獲取場景列表
  Future<List<Scene>> getScenes() async {
    _currentPage = 0;
    return _fetchScenes();
  }

  /// 獲取更多場景
  Future<List<Scene>> getMoreScenes() async {
    if (!_hasMore) return [];
    _currentPage++;
    return _fetchScenes();
  }

  Future<List<Scene>> _fetchScenes() async {
    try {
      if (_isCacheValid()) {
        _logger.info('使用緩存的場景數據');
        return _cachedScenes!;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      
      if (start >= _scenes.length) {
        _hasMore = false;
        return [];
      }
      
      final scenes = _scenes.sublist(
        start,
        end > _scenes.length ? _scenes.length : end,
      );
      
      _hasMore = end < _scenes.length;
      _cachedScenes = List.from(scenes);
      _lastCacheTime = DateTime.now();
      _logger.info('更新場景緩存');
      return scenes;
    } catch (e, stack) {
      _logger.error('獲取場景列表失敗', e, stack);
      rethrow;
    }
  }

  /// 獲取場景詳情
  Future<Scene> getSceneById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final scene = _scenes.firstWhere(
        (scene) => scene.id == id,
        orElse: () => throw Exception('找不到場景：$id'),
      );
      _logger.info('獲取場景：${scene.title}');
      return scene;
    } catch (e, stack) {
      _logger.error('獲取場景失敗：$id', e, stack);
      rethrow;
    }
  }

  /// 解鎖場景
  Future<void> unlockScene(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _scenes.indexWhere((scene) => scene.id == id);
      if (index == -1) {
        throw Exception('找不到場景：$id');
      }
      
      _scenes[index] = _scenes[index].unlock();
      _invalidateCache();
      _logger.info('解鎖場景：${_scenes[index].title}');
    } catch (e, stack) {
      _logger.error('解鎖場景失敗：$id', e, stack);
      rethrow;
    }
  }

  /// 增加瀏覽次數
  Future<void> incrementViewCount(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _scenes.indexWhere((scene) => scene.id == id);
      if (index == -1) {
        throw Exception('找不到場景：$id');
      }
      
      _scenes[index] = _scenes[index].updateStats(viewed: true);
      _invalidateCache();
      _logger.info('增加場景瀏覽次數：${_scenes[index].title}');
    } catch (e, stack) {
      _logger.error('增加場景瀏覽次數失敗：$id', e, stack);
      rethrow;
    }
  }

  /// 獲取推薦場景
  Future<List<Scene>> getRecommendedScenes({
    required DateTime date,
    required Map<String, dynamic> userPreferences,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // 模擬網絡請求

    final scenes = _scenes.map((scene) {
      final score = scene.calculateScore(
        date: date,
        userPreferences: userPreferences,
      );
      return scene.copyWith(baseScore: score);
    }).toList();

    scenes.sort((a, b) => b.baseScore.compareTo(a.baseScore));
    return scenes;
  }

  /// 獲取更多推薦場景
  Future<List<Scene>> getMoreRecommendedScenes({
    required DateTime date,
    required Map<String, dynamic> userPreferences,
    required Scene lastScene,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // 模擬網絡請求

    final lastIndex = _scenes.indexWhere((scene) => scene.id == lastScene.id);
    if (lastIndex == -1 || lastIndex >= _scenes.length - 1) {
      return [];
    }

    final nextScenes = _scenes.sublist(lastIndex + 1).map((scene) {
      final score = scene.calculateScore(
        date: date,
        userPreferences: userPreferences,
      );
      return scene.copyWith(baseScore: score);
    }).toList();

    nextScenes.sort((a, b) => b.baseScore.compareTo(a.baseScore));
    return nextScenes;
  }

  /// 更新場景統計
  Future<void> updateSceneStats(String sceneId, {
    bool? viewed,
    bool? used,
    bool? favorite,
  }) async {
    final index = _scenes.indexWhere((scene) => scene.id == sceneId);
    if (index == -1) return;

    _scenes[index] = _scenes[index].updateStats(
      viewed: viewed,
      used: used,
      favorite: favorite,
    );
  }

  /// 獲取用戶收藏的場景
  Future<List<Scene>> getFavoriteScenes() async {
    return _scenes.where((scene) => scene.isFavorite).toList();
  }

  /// 獲取特定類型的場景
  Future<List<Scene>> getScenesByType(SceneType type) async {
    return _scenes.where((scene) => scene.type == type).toList();
  }

  /// 搜索場景
  Future<List<Scene>> searchScenes(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _scenes.where((scene) {
      return scene.title.toLowerCase().contains(lowercaseQuery) ||
          scene.description.toLowerCase().contains(lowercaseQuery) ||
          scene.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// 檢查緩存是否有效
  bool _isCacheValid() {
    if (_cachedScenes == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheDuration;
  }

  /// 使緩存失效
  void _invalidateCache() {
    _cachedScenes = null;
    _lastCacheTime = null;
    _logger.info('清除場景緩存');
  }

  /// 清理資源
  void dispose() {
    _invalidateCache();
    _logger.info('釋放場景服務資源');
  }
} 