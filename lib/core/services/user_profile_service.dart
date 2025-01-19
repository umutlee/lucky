import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/user_profile.dart';
import 'package:all_lucky/core/services/storage_service.dart';

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(ref.read(storageServiceProvider));
});

class UserProfileService {
  static const String _profileKey = 'user_profile';
  static const String _onboardingKey = 'onboarding_completed';
  
  final StorageService _storage;
  UserProfile? _currentProfile;

  UserProfileService(this._storage);

  Future<void> init() async {
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileData = _storage.getData<Map<String, dynamic>>(_profileKey);
    if (profileData != null) {
      _currentProfile = UserProfile.fromJson(profileData);
    }
  }

  Future<void> updateUserType({required bool isGuest}) async {
    _currentProfile = (_currentProfile ?? UserProfile()).copyWith(isGuest: isGuest);
    await _saveProfile();
  }

  Future<void> updateBasicInfo({
    required String name,
    required String gender,
    required DateTime birthDateTime,
  }) async {
    _currentProfile = (_currentProfile ?? UserProfile()).copyWith(
      name: name,
      gender: gender,
      birthDateTime: birthDateTime,
    );
    await _saveProfile();
  }

  Future<void> updatePreferences({
    required List<String> fortuneTypes,
    required bool enableDailyNotification,
    required bool enableSolarTermNotification,
    required bool enableLuckyDayNotification,
  }) async {
    _currentProfile = (_currentProfile ?? UserProfile()).copyWith(
      preferredFortuneTypes: fortuneTypes,
      enableDailyNotification: enableDailyNotification,
      enableSolarTermNotification: enableSolarTermNotification,
      enableLuckyDayNotification: enableLuckyDayNotification,
    );
    await _saveProfile();
  }

  Future<void> _saveProfile() async {
    if (_currentProfile != null) {
      await _storage.saveData(_profileKey, _currentProfile!.toJson());
    }
  }

  Future<void> completeOnboarding() async {
    await _storage.saveData(_onboardingKey, true);
  }

  bool isOnboardingCompleted() {
    return _storage.getData<bool>(_onboardingKey) ?? false;
  }

  UserProfile? get currentProfile => _currentProfile;

  Future<void> clearProfile() async {
    await _storage.removeData(_profileKey);
    await _storage.removeData(_onboardingKey);
    _currentProfile = null;
  }
} 