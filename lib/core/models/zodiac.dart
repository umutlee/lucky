enum Zodiac {
  rat('鼠'),
  ox('牛'),
  tiger('虎'),
  rabbit('兔'),
  dragon('龍'),
  snake('蛇'),
  horse('馬'),
  goat('羊'),
  monkey('猴'),
  rooster('雞'),
  dog('狗'),
  pig('豬');

  final String name;
  const Zodiac(this.name);

  static Zodiac fromYear(int year) {
    final index = (year - 4) % 12;
    return Zodiac.values[index];
  }

  static Zodiac? fromName(String name) {
    return Zodiac.values.cast<Zodiac?>().firstWhere(
          (z) => z?.name == name,
          orElse: () => null,
        );
  }

  @override
  String toString() => name;
} 