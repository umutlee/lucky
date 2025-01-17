import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences.dart';
import '../models/fortune_display_config.dart';
import '../models/user_identity.dart';
import 'settings_provider.dart';

/// 用戶身份提供者
final userIdentityProvider = StateNotifierProvider<UserIdentityNotifier, UserIdentity>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserIdentityNotifier(prefs);
});

/// 運勢顯示配置提供者
final fortuneDisplayConfigProvider = StateNotifierProvider<FortuneDisplayConfigNotifier, FortuneDisplayConfig>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final identity = ref.watch(userIdentityProvider);
  return FortuneDisplayConfigNotifier(prefs, identity);
});

/// 用戶身份管理器
class UserIdentityNotifier extends StateNotifier<UserIdentity> {
  final SharedPreferences _prefs;
  static const String _key = 'user_identity';

  UserIdentityNotifier(this._prefs) : super(_loadInitialIdentity(_prefs));

  static UserIdentity _loadInitialIdentity(SharedPreferences prefs) {
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final data = jsonDecode(json);
        final type = UserIdentityType.values.firstWhere(
          (e) => e.toString() == 'UserIdentityType.${data['type']}',
        );
        return UserIdentity.defaultIdentities.firstWhere(
          (identity) => identity.type == type,
        );
      } catch (e) {
        // 如果加載失敗，返回預設身份
        return UserIdentity.defaultIdentities.first;
      }
    }
    return UserIdentity.defaultIdentities.first;
  }

  /// 更新用戶身份
  Future<void> updateIdentity(UserIdentity newIdentity) async {
    state = newIdentity;
    await _prefs.setString(_key, jsonEncode({
      'type': newIdentity.type.toString().split('.').last,
    }));
  }
}

/// 運勢顯示配置管理器
class FortuneDisplayConfigNotifier extends StateNotifier<FortuneDisplayConfig> {
  final SharedPreferences _prefs;
  final UserIdentity _identity;
  static const String _key = 'fortune_display_config';

  FortuneDisplayConfigNotifier(this._prefs, this._identity)
      : super(_loadInitialConfig(_prefs, _identity));

  static FortuneDisplayConfig _loadInitialConfig(
    SharedPreferences prefs,
    UserIdentity identity,
  ) {
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        return FortuneDisplayConfig.fromJson(jsonDecode(json));
      } catch (e) {
        // 如果加載失敗，返回基於身份的預設配置
        return FortuneDisplayConfig.forIdentity(identity);
      }
    }
    return FortuneDisplayConfig.forIdentity(identity);
  }

  /// 更新顯示順序
  Future<void> updateOrder(List<FortuneType> newOrder) async {
    state = state.updateOrder(newOrder);
    await _saveConfig();
  }

  /// 更新顯示狀態
  Future<void> updateVisibility(FortuneType type, bool isVisible) async {
    state = state.updateVisibility(type, isVisible);
    await _saveConfig();
  }

  /// 更新展開狀態
  Future<void> updateExpanded(FortuneType type, bool isExpanded) async {
    state = state.updateExpanded(type, isExpanded);
    await _saveConfig();
  }

  /// 重置為預設配置
  Future<void> resetToDefault() async {
    state = FortuneDisplayConfig.forIdentity(_identity);
    await _saveConfig();
  }

  /// 保存配置
  Future<void> _saveConfig() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }
} 