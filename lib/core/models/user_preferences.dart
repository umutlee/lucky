import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 2)
class UserPreferences extends HiveObject {
  @HiveField(0)
  final bool enableDailyNotification;

  @HiveField(1)
  final bool enableSolarTermNotification;

  @HiveField(2)
  final bool enableLuckyDayNotification;

  @HiveField(3)
  final String languageStyle;

  @HiveField(4)
  final List<String> preferredFortuneTypes;

  @HiveField(5)
  final bool enableDarkMode;

  @HiveField(6)
  final String notificationTime;

  @HiveField(7)
  final Map<String, dynamic> customSettings;

  UserPreferences({
    this.enableDailyNotification = true,
    this.enableSolarTermNotification = true,
    this.enableLuckyDayNotification = true,
    this.languageStyle = 'modern',
    List<String>? preferredFortuneTypes,
    this.enableDarkMode = false,
    this.notificationTime = '08:00',
    Map<String, dynamic>? customSettings,
  }) : 
    preferredFortuneTypes = preferredFortuneTypes ?? ['general', 'love', 'career', 'wealth'],
    customSettings = customSettings ?? {};

  UserPreferences copyWith({
    bool? enableDailyNotification,
    bool? enableSolarTermNotification,
    bool? enableLuckyDayNotification,
    String? languageStyle,
    List<String>? preferredFortuneTypes,
    bool? enableDarkMode,
    String? notificationTime,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      enableDailyNotification: enableDailyNotification ?? this.enableDailyNotification,
      enableSolarTermNotification: enableSolarTermNotification ?? this.enableSolarTermNotification,
      enableLuckyDayNotification: enableLuckyDayNotification ?? this.enableLuckyDayNotification,
      languageStyle: languageStyle ?? this.languageStyle,
      preferredFortuneTypes: preferredFortuneTypes ?? List.from(this.preferredFortuneTypes),
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      notificationTime: notificationTime ?? this.notificationTime,
      customSettings: customSettings ?? Map.from(this.customSettings),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableDailyNotification': enableDailyNotification,
      'enableSolarTermNotification': enableSolarTermNotification,
      'enableLuckyDayNotification': enableLuckyDayNotification,
      'languageStyle': languageStyle,
      'preferredFortuneTypes': preferredFortuneTypes,
      'enableDarkMode': enableDarkMode,
      'notificationTime': notificationTime,
      'customSettings': customSettings,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      enableDailyNotification: json['enableDailyNotification'] as bool? ?? true,
      enableSolarTermNotification: json['enableSolarTermNotification'] as bool? ?? true,
      enableLuckyDayNotification: json['enableLuckyDayNotification'] as bool? ?? true,
      languageStyle: json['languageStyle'] as String? ?? 'modern',
      preferredFortuneTypes: (json['preferredFortuneTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? ['general', 'love', 'career', 'wealth'],
      enableDarkMode: json['enableDarkMode'] as bool? ?? false,
      notificationTime: json['notificationTime'] as String? ?? '08:00',
      customSettings: json['customSettings'] as Map<String, dynamic>? ?? {},
    );
  }
} 