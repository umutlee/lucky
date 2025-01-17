import 'package:meta/meta.dart';
import 'user_identity.dart';

/// 運勢顯示配置
@immutable
class FortuneDisplayConfig {
  /// 運勢顯示順序
  final List<FortuneType> displayOrder;
  
  /// 運勢顯示開關
  final Map<FortuneType, bool> visibility;
  
  /// 運勢卡片展開狀態
  final Map<FortuneType, bool> expanded;

  const FortuneDisplayConfig({
    required this.displayOrder,
    required this.visibility,
    required this.expanded,
  });

  /// 創建預設配置
  factory FortuneDisplayConfig.defaultConfig() {
    final allTypes = FortuneType.values;
    return FortuneDisplayConfig(
      displayOrder: List.from(allTypes),
      visibility: Map.fromIterables(
        allTypes,
        List.filled(allTypes.length, true),
      ),
      expanded: Map.fromIterables(
        allTypes,
        List.filled(allTypes.length, true),
      ),
    );
  }

  /// 根據用戶身份創建配置
  factory FortuneDisplayConfig.forIdentity(UserIdentity identity) {
    final types = identity.fortuneTypes;
    return FortuneDisplayConfig(
      displayOrder: types,
      visibility: Map.fromIterables(
        types,
        List.filled(types.length, true),
      ),
      expanded: Map.fromIterables(
        types,
        List.filled(types.length, true),
      ),
    );
  }

  /// 從 JSON 創建實例
  factory FortuneDisplayConfig.fromJson(Map<String, dynamic> json) {
    return FortuneDisplayConfig(
      displayOrder: (json['displayOrder'] as List)
          .map((e) => FortuneType.values.firstWhere(
                (type) => type.toString() == 'FortuneType.$e',
              ))
          .toList(),
      visibility: Map.fromEntries(
        (json['visibility'] as Map).entries.map(
              (e) => MapEntry(
                FortuneType.values.firstWhere(
                  (type) => type.toString() == 'FortuneType.${e.key}',
                ),
                e.value as bool,
              ),
            ),
      ),
      expanded: Map.fromEntries(
        (json['expanded'] as Map).entries.map(
              (e) => MapEntry(
                FortuneType.values.firstWhere(
                  (type) => type.toString() == 'FortuneType.${e.key}',
                ),
                e.value as bool,
              ),
            ),
      ),
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'displayOrder': displayOrder
          .map((e) => e.toString().split('.').last)
          .toList(),
      'visibility': Map.fromEntries(
        visibility.entries.map(
          (e) => MapEntry(
            e.key.toString().split('.').last,
            e.value,
          ),
        ),
      ),
      'expanded': Map.fromEntries(
        expanded.entries.map(
          (e) => MapEntry(
            e.key.toString().split('.').last,
            e.value,
          ),
        ),
      ),
    };
  }

  /// 更新運勢顯示順序
  FortuneDisplayConfig updateOrder(List<FortuneType> newOrder) {
    return FortuneDisplayConfig(
      displayOrder: newOrder,
      visibility: visibility,
      expanded: expanded,
    );
  }

  /// 更新運勢顯示狀態
  FortuneDisplayConfig updateVisibility(FortuneType type, bool isVisible) {
    final newVisibility = Map<FortuneType, bool>.from(visibility);
    newVisibility[type] = isVisible;
    return FortuneDisplayConfig(
      displayOrder: displayOrder,
      visibility: newVisibility,
      expanded: expanded,
    );
  }

  /// 更新運勢卡片展開狀態
  FortuneDisplayConfig updateExpanded(FortuneType type, bool isExpanded) {
    final newExpanded = Map<FortuneType, bool>.from(expanded);
    newExpanded[type] = isExpanded;
    return FortuneDisplayConfig(
      displayOrder: displayOrder,
      visibility: visibility,
      expanded: newExpanded,
    );
  }

  /// 獲取可見的運勢類型
  List<FortuneType> get visibleTypes {
    return displayOrder.where((type) => visibility[type] ?? false).toList();
  }

  /// 檢查運勢類型是否展開
  bool isExpanded(FortuneType type) => expanded[type] ?? false;

  /// 檢查運勢類型是否可見
  bool isVisible(FortuneType type) => visibility[type] ?? false;
} 