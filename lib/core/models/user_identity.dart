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

/// 用戶身份模型
@freezed
class UserIdentity with _$UserIdentity {
  const factory UserIdentity({
    required String zodiac,
    required String constellation,
    @Default('') String name,
  }) = _UserIdentity;

  factory UserIdentity.fromJson(Map<String, dynamic> json) => _$UserIdentityFromJson(json);

  factory UserIdentity.initial() => const UserIdentity(
    zodiac: '鼠',
    constellation: '白羊座',
    name: '訪客',
  );
}

/// 預設身份列表
List<UserIdentity> get defaultIdentities => [
  // 現代族群
  UserIdentity(
    zodiac: '鼠',
    constellation: '白羊座',
    name: '學生黨',
  ),
  UserIdentity(
    zodiac: '牛',
    constellation: '金牛座',
    name: '上班族',
  ),
  UserIdentity(
    zodiac: '虎',
    constellation: '雙子座',
    name: '在職進修',
  ),
  UserIdentity(
    zodiac: '兔',
    constellation: '巨蟹座',
    name: '程序猿/媛',
  ),
  UserIdentity(
    zodiac: '龍',
    constellation: '獅子座',
    name: '社畜人',
  ),
  UserIdentity(
    zodiac: '蛇',
    constellation: '處女座',
    name: '工程獅',
  ),
  UserIdentity(
    zodiac: '馬',
    constellation: '天秤座',
    name: '宅宅',
  ),
  UserIdentity(
    zodiac: '羊',
    constellation: '天蝎座',
    name: '腐女子',
  ),
  UserIdentity(
    zodiac: '猴',
    constellation: '射手座',
    name: '傳統愛好者',
  ),
  UserIdentity(
    zodiac: '雞',
    constellation: '摩羯座',
    name: '銀髮族',
  ),
  UserIdentity(
    zodiac: '狗',
    constellation: '水瓶座',
    name: '命理愛好者',
  ),
  UserIdentity(
    zodiac: '豬',
    constellation: '雙魚座',
    name: '修行者',
  ),
  // 傳統族群
  UserIdentity(
    zodiac: '鼠',
    constellation: '子',
    name: '教育工作者',
  ),
  UserIdentity(
    zodiac: '牛',
    constellation: '丑',
    name: '藝術工作者',
  ),
  UserIdentity(
    zodiac: '虎',
    constellation: '寅',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '兔',
    constellation: '卯',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '龍',
    constellation: '辰',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '蛇',
    constellation: '巳',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '馬',
    constellation: '午',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '羊',
    constellation: '未',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '猴',
    constellation: '申',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '雞',
    constellation: '酉',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '狗',
    constellation: '戌',
    name: '訪客',
  ),
  UserIdentity(
    zodiac: '豬',
    constellation: '亥',
    name: '訪客',
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