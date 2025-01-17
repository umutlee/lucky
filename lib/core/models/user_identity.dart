import 'package:flutter/material.dart';

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
}

/// 用戶身份模型
class UserIdentity {
  final UserIdentityType type;
  final String name;
  final String description;
  final IconData icon;
  final List<String> tags;

  const UserIdentity({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.tags,
  });

  /// 預設身份列表
  static List<UserIdentity> get defaultIdentities => [
    UserIdentity(
      type: UserIdentityType.student,
      name: '學生黨',
      description: '為學業奮鬥中的莘莘學子',
      icon: Icons.school,
      tags: ['考試', '作業', '報告', '社團'],
    ),
    UserIdentity(
      type: UserIdentityType.worker,
      name: '上班族',
      description: '為生活打拼的社會新鮮人',
      icon: Icons.work,
      tags: ['工作', '職場', '人際', '升遷'],
    ),
    UserIdentity(
      type: UserIdentityType.both,
      name: '在職進修',
      description: '工作學習兩不誤的超人',
      icon: Icons.psychology,
      tags: ['時間管理', '效率', '平衡', '成長'],
    ),
    UserIdentity(
      type: UserIdentityType.programmer,
      name: '程序猿/媛',
      description: '碼農日常：Bug 與 Feature 的戰爭',
      icon: Icons.code,
      tags: ['編程', 'Debug', '加班', '頭髮'],
    ),
    UserIdentity(
      type: UserIdentityType.officeWorker,
      name: '社畜人',
      description: '為公司賣命的職場生物',
      icon: Icons.business_center,
      tags: ['加班', 'KPI', '會議', '報告'],
    ),
    UserIdentity(
      type: UserIdentityType.engineer,
      name: '工程獅',
      description: '用技術改變世界的工程師',
      icon: Icons.engineering,
      tags: ['專案', '技術', '創新', '靈感'],
    ),
    UserIdentity(
      type: UserIdentityType.otaku,
      name: '宅宅',
      description: '二次元與三次元的完美平衡者',
      icon: Icons.games,
      tags: ['動漫', '遊戲', '收藏', '社交'],
    ),
    UserIdentity(
      type: UserIdentityType.fujoshi,
      name: '腐女子',
      description: '腐世界的觀察家與評論家',
      icon: Icons.favorite,
      tags: ['同人', 'CP', '創作', '社群'],
    ),
  ];

  /// 根據身份類型獲取對應的運勢類型
  List<FortuneType> get fortuneTypes {
    switch (type) {
      case UserIdentityType.student:
        return [FortuneType.study, FortuneType.love];
      case UserIdentityType.worker:
        return [FortuneType.career, FortuneType.love];
      case UserIdentityType.both:
        return [FortuneType.study, FortuneType.career, FortuneType.love];
      case UserIdentityType.programmer:
        return [FortuneType.programming, FortuneType.career, FortuneType.love];
      case UserIdentityType.officeWorker:
        return [FortuneType.work, FortuneType.career, FortuneType.love];
      case UserIdentityType.engineer:
        return [FortuneType.tech, FortuneType.career, FortuneType.love];
      case UserIdentityType.otaku:
        return [FortuneType.entertainment, FortuneType.love];
      case UserIdentityType.fujoshi:
        return [FortuneType.creative, FortuneType.love];
    }
  }

  /// 獲取身份特定的運勢描述風格
  String getFortuneStyle(String baseDescription) {
    switch (type) {
      case UserIdentityType.programmer:
        return '今日代碼質量：$baseDescription';
      case UserIdentityType.officeWorker:
        return '今日社畜運勢：$baseDescription';
      case UserIdentityType.engineer:
        return '今日工程運勢：$baseDescription';
      case UserIdentityType.otaku:
        return '今日宅運：$baseDescription';
      case UserIdentityType.fujoshi:
        return '今日腐運：$baseDescription';
      default:
        return baseDescription;
    }
  }
}

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
} 