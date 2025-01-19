import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_identity.dart';

part 'user_onboarding.g.dart';
part 'user_onboarding.freezed.dart';

enum OnboardingStep {
  welcome,      // 歡迎頁面
  userType,     // 選擇用戶類型（訪客/註冊）
  identity,     // 選擇用戶身份
  basicInfo,    // 基本信息（姓名等）
  birthInfo,    // 生辰信息
  preferences,  // 偏好設置
  completed     // 完成引導
}

@freezed
class UserOnboarding with _$UserOnboarding {
  const factory UserOnboarding({
    required bool hasCompletedIntro,
    required OnboardingStep currentStep,
    required Map<OnboardingStep, bool> completedSteps,
    required Map<String, dynamic> tempData,
    @Default(LanguageStyle.modern) LanguageStyle selectedLanguageStyle,
  }) = _UserOnboarding;

  factory UserOnboarding.fromJson(Map<String, dynamic> json) =>
      _$UserOnboardingFromJson(json);

  factory UserOnboarding.initial() => UserOnboarding(
    hasCompletedIntro: false,
    currentStep: OnboardingStep.welcome,
    completedSteps: {
      for (var step in OnboardingStep.values) step: false
    },
    tempData: {},
    selectedLanguageStyle: LanguageStyle.modern,
  );
} 