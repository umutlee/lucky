import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_identity.freezed.dart';
part 'user_identity.g.dart';

/// 語言風格偏好
enum LanguageStyle {
  modern,    // 現代網路用語
  classical, // 傳統正式用語
}

/// 用戶身份類型
enum UserIdentityType {
  student,     // 學生黨
  worker,      // 上班族
  both,        // 在職進修
  programmer,  // 程序猿/媛
  officeWorker,// 社畜人
  engineer,    // 工程獅
  otaku,       // 宅宅
  fujoshi,     // 腐女子
  traditional, // 傳統愛好者
  elder,       // 銀髮族
  fortune,     // 命理愛好者
  spiritual,   // 修行者
  teacher,     // 教育工作者
  artist,      // 藝術工作者
  guest,       // 訪客模式
}

enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return '男';
      case Gender.female:
        return '女';
      case Gender.other:
        return '其他';
    }
  }
}

/// 用戶身份模型
@freezed
class UserIdentity with _$UserIdentity {
  const factory UserIdentity({
    required String id,
    required String name,
    required DateTime birthDate,
    required Gender gender,
    required String location,
    @Default(false) bool isProfileComplete,
  }) = _UserIdentity;

  factory UserIdentity.fromJson(Map<String, dynamic> json) => _$UserIdentityFromJson(json);

  factory UserIdentity.empty() => UserIdentity(
    id: '',
    name: '',
    birthDate: DateTime.now(),
    gender: Gender.other,
    location: '',
  );
}

/// 預設身份列表
List<UserIdentity> get defaultIdentities => [
  // 現代族群
  UserIdentity(
    id: '1',
    name: '學生黨',
    birthDate: DateTime(2000, 1, 1),
    gender: Gender.male,
    location: '台北',
  ),
  UserIdentity(
    id: '2',
    name: '上班族',
    birthDate: DateTime(1990, 5, 15),
    gender: Gender.male,
    location: '台中',
  ),
  UserIdentity(
    id: '3',
    name: '在職進修',
    birthDate: DateTime(1985, 10, 20),
    gender: Gender.male,
    location: '高雄',
  ),
  UserIdentity(
    id: '4',
    name: '程序猿/媛',
    birthDate: DateTime(1995, 3, 10),
    gender: Gender.male,
    location: '新竹',
  ),
  UserIdentity(
    id: '5',
    name: '社畜人',
    birthDate: DateTime(1980, 7, 5),
    gender: Gender.male,
    location: '台南',
  ),
  UserIdentity(
    id: '6',
    name: '工程獅',
    birthDate: DateTime(1975, 12, 30),
    gender: Gender.male,
    location: '台東',
  ),
  UserIdentity(
    id: '7',
    name: '宅宅',
    birthDate: DateTime(1990, 2, 15),
    gender: Gender.male,
    location: '花蓮',
  ),
  UserIdentity(
    id: '8',
    name: '腐女子',
    birthDate: DateTime(1995, 8, 25),
    gender: Gender.female,
    location: '屏東',
  ),
  UserIdentity(
    id: '9',
    name: '傳統愛好者',
    birthDate: DateTime(1980, 4, 10),
    gender: Gender.female,
    location: '宜蘭',
  ),
  UserIdentity(
    id: '10',
    name: '銀髮族',
    birthDate: DateTime(1965, 11, 20),
    gender: Gender.female,
    location: '台東',
  ),
  UserIdentity(
    id: '11',
    name: '命理愛好者',
    birthDate: DateTime(1970, 6, 5),
    gender: Gender.female,
    location: '花蓮',
  ),
  UserIdentity(
    id: '12',
    name: '修行者',
    birthDate: DateTime(1985, 9, 15),
    gender: Gender.female,
    location: '屏東',
  ),
  // 傳統族群
  UserIdentity(
    id: '13',
    name: '教育工作者',
    birthDate: DateTime(1975, 1, 1),
    gender: Gender.male,
    location: '台北',
  ),
  UserIdentity(
    id: '14',
    name: '藝術工作者',
    birthDate: DateTime(1980, 3, 15),
    gender: Gender.female,
    location: '台中',
  ),
  UserIdentity(
    id: '15',
    name: '訪客',
    birthDate: DateTime(1990, 1, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '16',
    name: '訪客',
    birthDate: DateTime(1990, 2, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '17',
    name: '訪客',
    birthDate: DateTime(1990, 3, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '18',
    name: '訪客',
    birthDate: DateTime(1990, 4, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '19',
    name: '訪客',
    birthDate: DateTime(1990, 5, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '20',
    name: '訪客',
    birthDate: DateTime(1990, 6, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '21',
    name: '訪客',
    birthDate: DateTime(1990, 7, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '22',
    name: '訪客',
    birthDate: DateTime(1990, 8, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '23',
    name: '訪客',
    birthDate: DateTime(1990, 9, 1),
    gender: Gender.other,
    location: '未知',
  ),
  UserIdentity(
    id: '24',
    name: '訪客',
    birthDate: DateTime(1990, 10, 1),
    gender: Gender.other,
    location: '未知',
  ),
];

/// 運勢類型
enum FortuneType {
  study,         // 學業運勢
  career,        // 事業運勢
  love,          // 愛情運勢
  programming,   // 編程運勢
  work,          // 工作運勢
  tech,          // 技術運勢
  entertainment, // 娛樂運勢
  creative,      // 創作運勢
  spiritual,     // 心靈運勢
  health,        // 健康運勢
  wisdom,        // 智慧運勢
  basic,         // 基本運勢（適用於訪客）
  zodiac,        // 生肖運勢
  horoscope,     // 星座運勢
} 