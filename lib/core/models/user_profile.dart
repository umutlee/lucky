import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_identity.dart';

part 'user_profile.g.dart';
part 'user_profile.freezed.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    String? email,
    required DateTime birthDateTime,
    required String birthPlace,
    required UserIdentityType identityType,
    required bool isGuest,
    required String calculatedZodiac,
    required String calculatedHoroscope,
    required List<FortuneType> preferredFortuneTypes,
    required LanguageStyle languageStyle,
    Map<String, dynamic>? additionalInfo,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => 
      _$UserProfileFromJson(json);

  factory UserProfile.guest() => UserProfile(
    id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
    name: '訪客',
    birthDateTime: DateTime.now(),
    birthPlace: '未知',
    identityType: UserIdentityType.guest,
    isGuest: true,
    calculatedZodiac: '',
    calculatedHoroscope: '',
    preferredFortuneTypes: [FortuneType.basic],
    languageStyle: LanguageStyle.modern,
  );
} 