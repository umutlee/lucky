import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_identity.dart';
import 'package:hive/hive.dart';

part 'user_profile.g.dart';
part 'user_profile.freezed.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String gender;

  @HiveField(2)
  DateTime birthDateTime;

  @HiveField(3)
  Map<String, dynamic> preferences;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  UserProfile({
    required this.name,
    required this.gender,
    required this.birthDateTime,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    preferences = preferences ?? {},
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      gender: json['gender'] as String,
      birthDateTime: DateTime.parse(json['birthDateTime'] as String),
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'birthDateTime': birthDateTime.toIso8601String(),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? gender,
    DateTime? birthDateTime,
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDateTime: birthDateTime ?? this.birthDateTime,
      preferences: preferences ?? Map<String, dynamic>.from(this.preferences),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory UserProfile.guest() => UserProfile(
    name: '訪客',
    gender: '',
    birthDateTime: DateTime.now(),
    preferences: {},
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
} 