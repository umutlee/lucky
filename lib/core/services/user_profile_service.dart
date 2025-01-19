import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:all_lucky/core/models/user_profile.dart';
import 'package:all_lucky/core/utils/date_utils.dart' as date_utils;

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

class UserProfileService {
  static const String _boxName = 'user_profile';
  static const String _currentProfileKey = 'current_profile';
  late Box<UserProfile> _box;
  UserProfile? _currentProfile;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProfileAdapter());
    _box = await Hive.openBox<UserProfile>(_boxName);
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    _currentProfile = _box.get(_currentProfileKey);
  }

  UserProfile? get currentProfile => _currentProfile;

  Future<void> updateBasicInfo({
    required String name,
    required String gender,
    required DateTime birthDateTime,
  }) async {
    final profile = _currentProfile?.copyWith(
      name: name,
      gender: gender,
      birthDateTime: birthDateTime,
      updatedAt: DateTime.now(),
    ) ?? UserProfile(
      name: name,
      gender: gender,
      birthDateTime: birthDateTime,
    );

    await _box.put(_currentProfileKey, profile);
    _currentProfile = profile;
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_currentProfile == null) {
      throw Exception('No current profile found');
    }

    final updatedProfile = _currentProfile!.copyWith(
      preferences: preferences,
      updatedAt: DateTime.now(),
    );

    await _box.put(_currentProfileKey, updatedProfile);
    _currentProfile = updatedProfile;
  }

  Future<void> clearCurrentProfile() async {
    await _box.delete(_currentProfileKey);
    _currentProfile = null;
  }

  String? getZodiacSign() {
    if (_currentProfile == null) return null;
    return date_utils.DateUtils.getZodiacSign(_currentProfile!.birthDateTime);
  }

  String? getChineseZodiac() {
    if (_currentProfile == null) return null;
    return date_utils.DateUtils.getChineseZodiac(_currentProfile!.birthDateTime);
  }

  int? getAge() {
    if (_currentProfile == null) return null;
    return date_utils.DateUtils.calculateAge(_currentProfile!.birthDateTime);
  }

  Future<void> dispose() async {
    await _box.close();
  }
} 