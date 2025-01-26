enum Zodiac {
  rat('鼠', '子'),
  ox('牛', '丑'),
  tiger('虎', '寅'),
  rabbit('兔', '卯'),
  dragon('龍', '辰'),
  snake('蛇', '巳'),
  horse('馬', '午'),
  goat('羊', '未'),
  monkey('猴', '申'),
  rooster('雞', '酉'),
  dog('狗', '戌'),
  pig('豬', '亥');

  final String name;
  final String earthlyBranch;

  const Zodiac(this.name, this.earthlyBranch);

  static Zodiac fromString(String value) {
    return Zodiac.values.firstWhere(
      (zodiac) => zodiac.name == value || zodiac.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Zodiac.rat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'earthlyBranch': earthlyBranch,
    };
  }

  static Zodiac fromJson(Map<String, dynamic> json) {
    return Zodiac.values.firstWhere(
      (zodiac) => zodiac.name == json['name'] || zodiac.earthlyBranch == json['earthlyBranch'],
      orElse: () => Zodiac.rat,
    );
  }

  String get description {
    switch (this) {
      case Zodiac.rat:
        return '機靈活潑，善於社交，具有領導才能';
      case Zodiac.ox:
        return '勤勉踏實，性格穩重，做事有耐心';
      case Zodiac.tiger:
        return '勇敢果斷，充滿活力，具有冒險精神';
      case Zodiac.rabbit:
        return '溫和善良，優雅有禮，富有同理心';
      case Zodiac.dragon:
        return '充滿魅力，意志堅強，追求完美';
      case Zodiac.snake:
        return '智慧敏銳，深思熟慮，具有洞察力';
      case Zodiac.horse:
        return '活力充沛，開朗樂觀，追求自由';
      case Zodiac.goat:
        return '溫順善良，富有藝術天分，重視和諧';
      case Zodiac.monkey:
        return '聰明靈活，創意豐富，適應力強';
      case Zodiac.rooster:
        return '勤奮自信，注重細節，追求完美';
      case Zodiac.dog:
        return '忠誠可靠，正直善良，富有責任感';
      case Zodiac.pig:
        return '真誠厚道，樂觀開朗，享受生活';
    }
  }

  String get element {
    switch (this) {
      case Zodiac.rat:
      case Zodiac.monkey:
        return '水';
      case Zodiac.ox:
      case Zodiac.rooster:
        return '金';
      case Zodiac.tiger:
      case Zodiac.horse:
        return '木';
      case Zodiac.rabbit:
      case Zodiac.pig:
        return '木';
      case Zodiac.dragon:
      case Zodiac.snake:
        return '土';
      case Zodiac.goat:
      case Zodiac.dog:
        return '火';
    }
  }

  String get direction {
    switch (this) {
      case Zodiac.rat:
        return '北';
      case Zodiac.ox:
        return '北北東';
      case Zodiac.tiger:
        return '東北東';
      case Zodiac.rabbit:
        return '東';
      case Zodiac.dragon:
        return '東南東';
      case Zodiac.snake:
        return '南南東';
      case Zodiac.horse:
        return '南';
      case Zodiac.goat:
        return '南南西';
      case Zodiac.monkey:
        return '西南西';
      case Zodiac.rooster:
        return '西';
      case Zodiac.dog:
        return '西北西';
      case Zodiac.pig:
        return '北北西';
    }
  }

  String get season {
    switch (this) {
      case Zodiac.rat:
      case Zodiac.ox:
      case Zodiac.tiger:
        return '冬';
      case Zodiac.rabbit:
      case Zodiac.dragon:
      case Zodiac.snake:
        return '春';
      case Zodiac.horse:
      case Zodiac.goat:
      case Zodiac.monkey:
        return '夏';
      case Zodiac.rooster:
      case Zodiac.dog:
      case Zodiac.pig:
        return '秋';
    }
  }

  String get time {
    switch (this) {
      case Zodiac.rat:
        return '23:00-01:00';
      case Zodiac.ox:
        return '01:00-03:00';
      case Zodiac.tiger:
        return '03:00-05:00';
      case Zodiac.rabbit:
        return '05:00-07:00';
      case Zodiac.dragon:
        return '07:00-09:00';
      case Zodiac.snake:
        return '09:00-11:00';
      case Zodiac.horse:
        return '11:00-13:00';
      case Zodiac.goat:
        return '13:00-15:00';
      case Zodiac.monkey:
        return '15:00-17:00';
      case Zodiac.rooster:
        return '17:00-19:00';
      case Zodiac.dog:
        return '19:00-21:00';
      case Zodiac.pig:
        return '21:00-23:00';
    }
  }

  @override
  String toString() => name;
} 