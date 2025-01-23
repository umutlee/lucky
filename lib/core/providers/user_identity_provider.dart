import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_identity.dart';
import '../services/sqlite_preferences_service.dart';

final userIdentityProvider = StateNotifierProvider<UserIdentityNotifier, UserIdentity>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return UserIdentityNotifier(prefsService);
});

class UserIdentityNotifier extends StateNotifier<UserIdentity> {
  final SQLitePreferencesService _prefsService;

  UserIdentityNotifier(this._prefsService) : super(UserIdentity.initial()) {
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    try {
      final zodiac = await _prefsService.getValue<String>('user_zodiac') ?? '鼠';
      final constellation = await _prefsService.getValue<String>('user_constellation') ?? '白羊座';
      state = UserIdentity(zodiac: zodiac, constellation: constellation);
    } catch (e) {
      // 如果加載失敗，保持初始狀態
      print('加載用戶身份失敗: $e');
    }
  }

  Future<void> updateIdentity({String? zodiac, String? constellation}) async {
    try {
      if (zodiac != null) {
        await _prefsService.setValue('user_zodiac', zodiac);
      }
      if (constellation != null) {
        await _prefsService.setValue('user_constellation', constellation);
      }
      state = UserIdentity(
        zodiac: zodiac ?? state.zodiac,
        constellation: constellation ?? state.constellation,
      );
    } catch (e) {
      print('更新用戶身份失敗: $e');
      // 可以在這裡添加錯誤處理邏輯
    }
  }
} 