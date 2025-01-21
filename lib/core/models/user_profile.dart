import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_identity.dart';
import 'package:hive/hive.dart';

part 'user_profile.g.dart';
part 'user_profile.freezed.dart';

@freezed
@HiveType(typeId: 0)
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @HiveField(0)
    required String name,
    @HiveField(1)
    required String gender,
    @HiveField(2)
    required DateTime birthDateTime,
    @HiveField(3)
    @Default({})
    Map<String, dynamic> preferences,
    @HiveField(4)
    DateTime? createdAt,
    @HiveField(5)
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
      
  factory UserProfile.guest() => UserProfile(
    name: '訪客',
    gender: '',
    birthDateTime: DateTime.now(),
    preferences: const {},
  );
} 