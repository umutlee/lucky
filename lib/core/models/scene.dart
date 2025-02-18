import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'fortune_type.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

enum SceneType {
  study('學習'),
  love('戀愛'),
  career('事業'),
  wealth('財運'),
  health('健康'),
  travel('旅行');

  final String displayName;
  const SceneType(this.displayName);
}

class IconDataConverter implements JsonConverter<IconData, int> {
  const IconDataConverter();

  @override
  IconData fromJson(int json) => IconData(json);

  @override
  int toJson(IconData object) => object.codePoint;
}

/// 場景模型
@freezed
class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String title,
    required String description,
    @IconDataConverter() required IconData icon,
    required SceneType type,
    String? imageUrl,
    @Default(false) bool isLocked,
    @Default(false) bool isFavorite,
    @Default(0) int viewCount,
    @Default(0) int useCount,
    @Default(0) int baseScore,
    DateTime? lastViewedAt,
    String? unlockCondition,
    @Default([]) List<String> tags,
  }) = _Scene;

  /// 從 JSON 創建
  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

  const Scene._();  // 添加私有構造函數

  bool get isPopular => viewCount > 1000;
  bool get isNew => lastViewedAt == null;
  bool get isFrequentlyUsed => useCount > 10;

  String get name => title;
  String get shortDescription => description.length > 50 
    ? '${description.substring(0, 47)}...' 
    : description;

  String get imagePath => imageUrl ?? '';

  List<String> get displayTags => [
    ...tags,
    if (isPopular) '熱門',
    if (isNew) '新上架',
    if (isFrequentlyUsed) '常用',
  ];

  /// 計算場景分數
  int calculateScore({
    required DateTime date,
    required Map<String, dynamic> userPreferences,
  }) {
    int score = baseScore;

    // 根據日期調整分數
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month) {
      score += 10;  // 本月場景加分
    }

    // 根據用戶偏好調整分數
    if (userPreferences['favoriteTypes']?.contains(type.name) ?? false) {
      score += 15;  // 用戶喜好類型加分
    }

    if (userPreferences['tags']?.any((tag) => tags.contains(tag)) ?? false) {
      score += 5;  // 標籤匹配加分
    }

    // 根據使用情況調整分數
    if (isPopular) score += 8;
    if (isNew) score += 5;
    if (isFrequentlyUsed) score -= 3;  // 避免過度推薦

    return score.clamp(0, 100);  // 確保分數在 0-100 範圍內
  }

  /// 更新場景統計
  Scene updateStats({
    bool? viewed,
    bool? used,
    bool? favorite,
  }) {
    return copyWith(
      viewCount: viewed == true ? viewCount + 1 : viewCount,
      useCount: used == true ? useCount + 1 : useCount,
      lastViewedAt: used == true ? DateTime.now() : lastViewedAt,
      isFavorite: favorite ?? isFavorite,
    );
  }

  /// 解鎖場景
  Scene unlock() => copyWith(isLocked: false);

  /// 鎖定場景
  Scene lock() => copyWith(isLocked: true);
} 