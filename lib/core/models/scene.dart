import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune_type.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

@freezed
class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String name,
    required String description,
    required String imagePath,
    required FortuneType type,
    required double baseScore,
    @Default([]) List<String> tags,
    @Default(false) bool isUnlocked,
    String? unlockCondition,
    @Default(0) int viewCount,
    DateTime? lastViewedAt,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

  const Scene._();

  bool get isLocked => !isUnlocked;

  String get displayName => name;

  String get imageAsset => imagePath;

  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
        description.toLowerCase().contains(lowercaseQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }

  FortuneType get fortuneType => type;
} 