import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_identity.dart';
import '../utils/logger.dart';

final userStorageProvider = Provider<UserStorage>((ref) {
  final logger = Logger('UserStorage');
  return UserStorage(logger);
});

class UserStorage {
  static const String _userKey = 'user_data';
  final Logger _logger;

  UserStorage(this._logger);

  Future<void> saveUser(UserIdentity user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      _logger.info('用戶數據保存成功');
    } catch (e) {
      _logger.error('保存用戶數據失敗', e);
      rethrow;
    }
  }

  Future<UserIdentity> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) {
        return UserIdentity.empty();
      }
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserIdentity.fromJson(userData);
    } catch (e) {
      _logger.error('獲取用戶數據失敗', e);
      return UserIdentity.empty();
    }
  }

  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      _logger.info('用戶數據清除成功');
    } catch (e) {
      _logger.error('清除用戶數據失敗', e);
      rethrow;
    }
  }
} 