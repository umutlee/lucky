import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene.dart';
import '../services/scene_service.dart';

final sceneProvider = FutureProvider<List<Scene>>((ref) async {
  final sceneService = ref.watch(sceneServiceProvider);
  return sceneService.getScenes();
});

final selectedSceneProvider = StateProvider<Scene?>((ref) => null); 