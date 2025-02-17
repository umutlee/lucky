enum FortuneLevel {
  superLucky,
  lucky,
  smallLucky,
  normal,
  unlucky;

  String get displayName {
    switch (this) {
      case FortuneLevel.superLucky:
        return '大吉';
      case FortuneLevel.lucky:
        return '吉';
      case FortuneLevel.smallLucky:
        return '小吉';
      case FortuneLevel.normal:
        return '平';
      case FortuneLevel.unlucky:
        return '凶';
    }
  }

  static FortuneLevel fromScore(int score) {
    if (score >= 90) return FortuneLevel.superLucky;
    if (score >= 75) return FortuneLevel.lucky;
    if (score >= 60) return FortuneLevel.smallLucky;
    if (score >= 40) return FortuneLevel.normal;
    return FortuneLevel.unlucky;
  }
} 