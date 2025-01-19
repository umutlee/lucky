import 'package:hive/hive.dart';

part 'user_onboarding.g.dart';

@HiveType(typeId: 1)
class UserOnboarding extends HiveObject {
  @HiveField(0)
  final bool hasCompletedBasicInfo;

  @HiveField(1)
  final bool hasCompletedPreferences;

  @HiveField(2)
  final bool hasCompletedTutorial;

  @HiveField(3)
  final DateTime? completedAt;

  UserOnboarding({
    this.hasCompletedBasicInfo = false,
    this.hasCompletedPreferences = false,
    this.hasCompletedTutorial = false,
    this.completedAt,
  });

  bool get isCompleted => 
    hasCompletedBasicInfo && 
    hasCompletedPreferences && 
    hasCompletedTutorial;

  UserOnboarding copyWith({
    bool? hasCompletedBasicInfo,
    bool? hasCompletedPreferences,
    bool? hasCompletedTutorial,
    DateTime? completedAt,
  }) {
    return UserOnboarding(
      hasCompletedBasicInfo: hasCompletedBasicInfo ?? this.hasCompletedBasicInfo,
      hasCompletedPreferences: hasCompletedPreferences ?? this.hasCompletedPreferences,
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
      completedAt: completedAt ?? this.completedAt,
    );
  }
} 