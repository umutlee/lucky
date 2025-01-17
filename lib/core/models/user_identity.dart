import 'package:flutter/material.dart';

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
class UserIdentity {
  final UserIdentityType type;
  final String name;
  final String description;
  final IconData icon;
  final List<String> tags;
  final LanguageStyle languageStyle;

  const UserIdentity({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.tags,
    this.languageStyle = LanguageStyle.modern,
  });

  /// 預設身份列表
  static List<UserIdentity> get defaultIdentities => [
    // 現代族群
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
    // 傳統族群
    UserIdentity(
      type: UserIdentityType.traditional,
      name: '傳統愛好者',
      description: '喜愛傳統文化與經典內容',
      icon: Icons.auto_stories,
      tags: ['傳統', '文化', '典故', '禮儀'],
      languageStyle: LanguageStyle.classical,
    ),
    UserIdentity(
      type: UserIdentityType.elder,
      name: '銀髮族',
      description: '優雅生活的智慧長者',
      icon: Icons.elderly,
      tags: ['養生', '休閒', '保健', '生活'],
      languageStyle: LanguageStyle.classical,
    ),
    UserIdentity(
      type: UserIdentityType.fortune,
      name: '命理愛好者',
      description: '探索八字與玄學的追求者',
      icon: Icons.brightness_4,
      tags: ['命理', '風水', '占卜', '預測'],
      languageStyle: LanguageStyle.classical,
    ),
    UserIdentity(
      type: UserIdentityType.spiritual,
      name: '修行者',
      description: '追求心靈提升的修行人',
      icon: Icons.self_improvement,
      tags: ['修行', '冥想', '靜心', '修養'],
      languageStyle: LanguageStyle.classical,
    ),
    UserIdentity(
      type: UserIdentityType.teacher,
      name: '教育工作者',
      description: '春風化雨的教育園丁',
      icon: Icons.cast_for_education,
      tags: ['教學', '育人', '知識', '傳承'],
      languageStyle: LanguageStyle.classical,
    ),
    UserIdentity(
      type: UserIdentityType.artist,
      name: '藝術工作者',
      description: '追求美的創作者',
      icon: Icons.palette,
      tags: ['藝術', '創作', '美學', '靈感'],
      languageStyle: LanguageStyle.classical,
    ),
  ];

  /// 根據身份類型獲取對應的運勢類型
  List<FortuneType> get fortuneTypes {
    // 訪客模式只顯示基本運勢
    if (type == UserIdentityType.guest) {
      return [FortuneType.basic];
    }

    // 基礎運勢列表（所有用戶都會顯示）
    final List<FortuneType> baseTypes = [FortuneType.zodiac, FortuneType.horoscope];
    
    // 根據身份添加特定運勢
    switch (type) {
      case UserIdentityType.student:
        return [...baseTypes, FortuneType.study, FortuneType.love];
      case UserIdentityType.worker:
        return [...baseTypes, FortuneType.career, FortuneType.love];
      case UserIdentityType.both:
        return [...baseTypes, FortuneType.study, FortuneType.career, FortuneType.love];
      case UserIdentityType.programmer:
        return [...baseTypes, FortuneType.programming, FortuneType.career, FortuneType.love];
      case UserIdentityType.officeWorker:
        return [...baseTypes, FortuneType.work, FortuneType.career, FortuneType.love];
      case UserIdentityType.engineer:
        return [...baseTypes, FortuneType.tech, FortuneType.career, FortuneType.love];
      case UserIdentityType.otaku:
        return [...baseTypes, FortuneType.entertainment, FortuneType.love];
      case UserIdentityType.fujoshi:
        return [...baseTypes, FortuneType.creative, FortuneType.love];
      case UserIdentityType.traditional:
      case UserIdentityType.elder:
      case UserIdentityType.fortune:
      case UserIdentityType.spiritual:
      case UserIdentityType.teacher:
      case UserIdentityType.artist:
        return [...baseTypes, FortuneType.spiritual, FortuneType.health, FortuneType.wisdom];
      case UserIdentityType.guest:
        return [FortuneType.basic]; // 訪客模式
    }
  }

  /// 獲取身份特定的運勢描述風格
  String getFortuneStyle(String baseDescription) {
    if (languageStyle == LanguageStyle.classical) {
      return baseDescription; // 使用原始描述，不加入特殊風格
    }
    
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
  spiritual,     // 心靈運勢
  health,        // 健康運勢
  wisdom,        // 智慧運勢
  basic,         // 基本運勢（適用於訪客）
  zodiac,        // 生肖運勢
  horoscope,     // 星座運勢
} 