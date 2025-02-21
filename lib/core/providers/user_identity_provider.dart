import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_identity.dart';
import '../services/sqlite_preferences_service.dart';

final userIdentityProvider = StateNotifierProvider<UserIdentityNotifier, UserIdentity>((ref) {
  final prefsService = ref.watch(sqlitePreferencesServiceProvider);
  return UserIdentityNotifier(prefsService);
});

class UserIdentityNotifier extends StateNotifier<UserIdentity> {
  final SQLitePreferencesService _prefsService;

  UserIdentityNotifier(this._prefsService) : super(UserIdentity.empty()) {
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    try {
      final id = await _prefsService.getValue<String>('user_id') ?? '';
      final name = await _prefsService.getValue<String>('user_name') ?? '';
      final birthDateStr = await _prefsService.getValue<String>('user_birth_date');
      final birthDate = birthDateStr != null ? DateTime.parse(birthDateStr) : DateTime.now();
      final genderStr = await _prefsService.getValue<String>('user_gender') ?? 'other';
      final gender = Gender.values.firstWhere(
        (g) => g.name == genderStr,
        orElse: () => Gender.other,
      );
      final location = await _prefsService.getValue<String>('user_location') ?? '';
      
      state = UserIdentity(
        id: id,
        name: name,
        birthDate: birthDate,
        gender: gender,
        location: location,
      );
    } catch (e) {
      // 如果加載失敗，保持初始狀態
      print('加載用戶身份失敗: $e');
    }
  }

  Future<void> updateIdentity({
    String? id,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    String? location,
  }) async {
    try {
      if (id != null) {
        await _prefsService.setValue('user_id', id);
      }
      if (name != null) {
        await _prefsService.setValue('user_name', name);
      }
      if (birthDate != null) {
        await _prefsService.setValue('user_birth_date', birthDate.toIso8601String());
      }
      if (gender != null) {
        await _prefsService.setValue('user_gender', gender.name);
      }
      if (location != null) {
        await _prefsService.setValue('user_location', location);
      }

      state = UserIdentity(
        id: id ?? state.id,
        name: name ?? state.name,
        birthDate: birthDate ?? state.birthDate,
        gender: gender ?? state.gender,
        location: location ?? state.location,
      );
    } catch (e) {
      print('更新用戶身份失敗: $e');
      // 可以在這裡添加錯誤處理邏輯
    }
  }
} 