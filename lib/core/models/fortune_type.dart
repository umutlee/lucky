enum FortuneType {
  general('總運', '整體運勢預測'),
  love('愛情', '愛情運勢預測'),
  career('事業', '事業運勢預測'),
  wealth('財運', '財運運勢預測');

  final String name;
  final String description;

  const FortuneType(this.name, this.description);
} 