import 'package:flutter/foundation.dart';

class UserSettings {
  final String zodiac;
  final int birthYear;
  final bool enableNotifications;
  final List<String> preferredFortuneTypes;

  const UserSettings({
    required this.zodiac,
    required this.birthYear,
    this.enableNotifications = true,
    this.preferredFortuneTypes = const ['日常', '事業', '學習', '財運', '人際'],
  });

  UserSettings copyWith({
    String? zodiac,
    int? birthYear,
    bool? enableNotifications,
    List<String>? preferredFortuneTypes,
  }) {
    return UserSettings(
      zodiac: zodiac ?? this.zodiac,
      birthYear: birthYear ?? this.birthYear,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      preferredFortuneTypes: preferredFortuneTypes ?? this.preferredFortuneTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zodiac': zodiac,
      'birthYear': birthYear,
      'enableNotifications': enableNotifications,
      'preferredFortuneTypes': preferredFortuneTypes,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      zodiac: json['zodiac'] as String,
      birthYear: json['birthYear'] as int,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      preferredFortuneTypes: List<String>.from(json['preferredFortuneTypes'] as List? ?? 
        ['日常', '事業', '學習', '財運', '人際']),
    );
  }

  // 默認設置
  factory UserSettings.defaultSettings() {
    final currentYear = DateTime.now().year;
    return UserSettings(
      zodiac: '龍', // 2024年是龍年
      birthYear: currentYear - 20, // 默認年齡20歲
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          zodiac == other.zodiac &&
          birthYear == other.birthYear &&
          enableNotifications == other.enableNotifications &&
          listEquals(preferredFortuneTypes, other.preferredFortuneTypes);

  @override
  int get hashCode =>
      zodiac.hashCode ^
      birthYear.hashCode ^
      enableNotifications.hashCode ^
      preferredFortuneTypes.hashCode;
} 