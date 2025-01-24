/// 運勢類型枚舉
enum FortuneType {
  general('總運', '整體運勢預測'),
  study('學業', '學業運勢預測'),
  career('事業', '事業運勢預測'),
  love('愛情', '愛情運勢預測'),
  wealth('財運', '財運運勢預測'),
  programming('編程', '編程運勢預測'),
  work('工作', '工作運勢預測'),
  tech('技術', '技術運勢預測'),
  entertainment('娛樂', '娛樂運勢預測'),
  creative('創作', '創作運勢預測'),
  spiritual('心靈', '心靈運勢預測'),
  health('健康', '健康運勢預測'),
  wisdom('智慧', '智慧運勢預測'),
  basic('基礎', '基本運勢預測'),
  zodiac('生肖', '生肖運勢預測'),
  horoscope('星座', '星座運勢預測');

  final String name;
  final String description;

  const FortuneType(this.name, this.description);

  /// 獲取運勢類型的顯示名稱
  String get displayName => name;

  /// 獲取運勢類型的詳細描述
  String get detailedDescription => description;

  /// 檢查是否為基礎運勢類型
  bool get isBasicType => 
    this == general || 
    this == study || 
    this == career || 
    this == love || 
    this == wealth;

  /// 檢查是否為特殊運勢類型
  bool get isSpecialType => !isBasicType;

  /// 獲取運勢類型的圖標名稱
  String get iconName {
    switch (this) {
      case FortuneType.general:
        return 'assets/icons/fortune_general.png';
      case FortuneType.study:
        return 'assets/icons/fortune_study.png';
      case FortuneType.career:
        return 'assets/icons/fortune_career.png';
      case FortuneType.love:
        return 'assets/icons/fortune_love.png';
      case FortuneType.wealth:
        return 'assets/icons/fortune_wealth.png';
      case FortuneType.programming:
        return 'assets/icons/fortune_programming.png';
      case FortuneType.work:
        return 'assets/icons/fortune_work.png';
      case FortuneType.tech:
        return 'assets/icons/fortune_tech.png';
      case FortuneType.entertainment:
        return 'assets/icons/fortune_entertainment.png';
      case FortuneType.creative:
        return 'assets/icons/fortune_creative.png';
      case FortuneType.spiritual:
        return 'assets/icons/fortune_spiritual.png';
      case FortuneType.health:
        return 'assets/icons/fortune_health.png';
      case FortuneType.wisdom:
        return 'assets/icons/fortune_wisdom.png';
      case FortuneType.basic:
        return 'assets/icons/fortune_basic.png';
      case FortuneType.zodiac:
        return 'assets/icons/fortune_zodiac.png';
      case FortuneType.horoscope:
        return 'assets/icons/fortune_horoscope.png';
    }
  }
} 