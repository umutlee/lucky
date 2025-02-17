import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_identity.dart';
import '../services/user_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserIdentity>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserNotifier(userService);
});

class UserNotifier extends StateNotifier<UserIdentity> {
  final UserService _userService;

  UserNotifier(this._userService) : super(UserIdentity.empty()) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final user = await _userService.getCurrentUser();
      state = user;
    } catch (e) {
      // 如果獲取用戶信息失敗，保持空狀態
    }
  }

  Future<void> updateBirthDate(DateTime birthDate) async {
    try {
      final updatedUser = await _userService.updateBirthDate(birthDate);
      state = updatedUser;
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  Future<void> updateName(String name) async {
    try {
      final updatedUser = await _userService.updateName(name);
      state = updatedUser;
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  Future<void> updateGender(Gender gender) async {
    try {
      final updatedUser = await _userService.updateGender(gender);
      state = updatedUser;
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }

  Future<void> updateLocation(String location) async {
    try {
      final updatedUser = await _userService.updateLocation(location);
      state = updatedUser;
    } catch (e) {
      // 處理錯誤
      rethrow;
    }
  }
} 