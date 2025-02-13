import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

@freezed
class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String name,
    required String description,
    required String imageAsset,
    required String type,
    required Map<String, dynamic> parameters,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
} 