import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/user_onboarding.dart';
import '../models/user_identity.dart';
import '../utils/zodiac_calculator.dart';
import '../utils/horoscope_calculator.dart';

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

class UserProfileService {
  static const String _profileKey = 'user_profile';
  static const String _onboardingKey = 'user_onboarding';
  
  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);
    if (profileJson == null) return null;
    return UserProfile.fromJson(jsonDecode(profileJson));
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserOnboarding> loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final String? onboardingJson = prefs.getString(_onboardingKey);
    if (onboardingJson == null) return UserOnboarding.initial();
    return UserOnboarding.fromJson(jsonDecode(onboardingJson));
  }

  Future<void> saveOnboarding(UserOnboarding onboarding) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingKey, jsonEncode(onboarding.toJson()));
  }

  Future<UserProfile> createProfileFromBirthInfo({
    required String name,
    String? email,
    required DateTime birthDateTime,
    required String birthPlace,
    required UserIdentityType identityType,
    required bool isGuest,
  }) async {
    final String zodiac = ZodiacCalculator.calculateZodiac(birthDateTime);
    final String horoscope = HoroscopeCalculator.calculateHoroscope(birthDateTime);
    
    // 根據身份類型獲取對應的運勢類型和語言風格
    final identity = UserIdentity.defaultIdentities
        .firstWhere((i) => i.type == identityType);
    
    final profile = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      birthDateTime: birthDateTime,
      birthPlace: birthPlace,
      identityType: identityType,
      isGuest: isGuest,
      calculatedZodiac: zodiac,
      calculatedHoroscope: horoscope,
      preferredFortuneTypes: identity.fortuneTypes,
      languageStyle: identity.languageStyle,
    );

    await saveProfile(profile);
    return profile;
  }

  Future<void> completeOnboardingStep(OnboardingStep step) async {
    final onboarding = await loadOnboarding();
    final updatedSteps = Map<OnboardingStep, bool>.from(onboarding.completedSteps);
    updatedSteps[step] = true;

    final nextStep = _getNextStep(step);
    
    final updatedOnboarding = onboarding.copyWith(
      currentStep: nextStep,
      completedSteps: updatedSteps,
      hasCompletedIntro: nextStep == OnboardingStep.completed,
    );

    await saveOnboarding(updatedOnboarding);
  }

  OnboardingStep _getNextStep(OnboardingStep currentStep) {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex < steps.length - 1) {
      return steps[currentIndex + 1];
    }
    return OnboardingStep.completed;
  }

  Future<void> saveTempData(String key, dynamic value) async {
    final onboarding = await loadOnboarding();
    final updatedTempData = Map<String, dynamic>.from(onboarding.tempData);
    updatedTempData[key] = value;
    
    await saveOnboarding(onboarding.copyWith(tempData: updatedTempData));
  }

  Future<bool> isOnboardingCompleted() async {
    final onboarding = await loadOnboarding();
    return onboarding.hasCompletedIntro;
  }

  Future<void> updateLanguageStyle(LanguageStyle style) async {
    final onboarding = await loadOnboarding();
    await saveOnboarding(onboarding.copyWith(selectedLanguageStyle: style));
    
    final profile = await loadProfile();
    if (profile != null) {
      await saveProfile(profile.copyWith(languageStyle: style));
    }
  }
} 