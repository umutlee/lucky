enum ChineseZodiac {
  rat,
  ox,
  tiger,
  rabbit,
  dragon,
  snake,
  horse,
  goat,
  monkey,
  rooster,
  dog,
  pig;

  String get displayName {
    switch (this) {
      case ChineseZodiac.rat:
        return '鼠';
      case ChineseZodiac.ox:
        return '牛';
      case ChineseZodiac.tiger:
        return '虎';
      case ChineseZodiac.rabbit:
        return '兔';
      case ChineseZodiac.dragon:
        return '龍';
      case ChineseZodiac.snake:
        return '蛇';
      case ChineseZodiac.horse:
        return '馬';
      case ChineseZodiac.goat:
        return '羊';
      case ChineseZodiac.monkey:
        return '猴';
      case ChineseZodiac.rooster:
        return '雞';
      case ChineseZodiac.dog:
        return '狗';
      case ChineseZodiac.pig:
        return '豬';
    }
  }

  String get element {
    switch (this) {
      case ChineseZodiac.rat:
      case ChineseZodiac.dragon:
      case ChineseZodiac.monkey:
        return '水';
      case ChineseZodiac.ox:
      case ChineseZodiac.snake:
      case ChineseZodiac.rooster:
        return '金';
      case ChineseZodiac.tiger:
      case ChineseZodiac.horse:
      case ChineseZodiac.dog:
        return '木';
      case ChineseZodiac.rabbit:
      case ChineseZodiac.goat:
      case ChineseZodiac.pig:
        return '火';
    }
  }

  String get description {
    switch (this) {
      case ChineseZodiac.rat:
        return '機靈活潑，善於社交，但有時過於謹慎';
      case ChineseZodiac.ox:
        return '勤勞踏實，意志堅定，但有時固執';
      case ChineseZodiac.tiger:
        return '勇敢果斷，充滿魅力，但有時過於衝動';
      case ChineseZodiac.rabbit:
        return '溫和優雅，善解人意，但有時優柔寡斷';
      case ChineseZodiac.dragon:
        return '充滿活力，雄心壯志，但有時過於自信';
      case ChineseZodiac.snake:
        return '智慧敏銳，優雅神秘，但有時心機重';
      case ChineseZodiac.horse:
        return '活潑開朗，追求自由，但有時難以安定';
      case ChineseZodiac.goat:
        return '溫順善良，富有同情心，但有時優柔寡斷';
      case ChineseZodiac.monkey:
        return '聰明機智，創意十足，但有時過於狡猾';
      case ChineseZodiac.rooster:
        return '勤奮務實，注重細節，但有時過於挑剔';
      case ChineseZodiac.dog:
        return '忠誠可靠，正直善良，但有時過於固執';
      case ChineseZodiac.pig:
        return '善良誠實，樂觀開朗，但有時過於天真';
    }
  }
} 