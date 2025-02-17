import '../models/compass_direction.dart';

class DirectionHelper {
  static String getDirectionName(CompassPoint direction) {
    switch (direction) {
      case CompassPoint.north:
        return '北';
      case CompassPoint.northEast:
        return '東北';
      case CompassPoint.east:
        return '東';
      case CompassPoint.southEast:
        return '東南';
      case CompassPoint.south:
        return '南';
      case CompassPoint.southWest:
        return '西南';
      case CompassPoint.west:
        return '西';
      case CompassPoint.northWest:
        return '西北';
    }
  }

  static String getDirectionDescription(CompassPoint direction) {
    switch (direction) {
      case CompassPoint.north:
        return '北方代表事業與成就，適合規劃未來';
      case CompassPoint.northEast:
        return '東北方代表學習與知識，適合求學進修';
      case CompassPoint.east:
        return '東方代表家庭與健康，適合修身養性';
      case CompassPoint.southEast:
        return '東南方代表財富與收入，適合投資理財';
      case CompassPoint.south:
        return '南方代表名譽與地位，適合拓展人脈';
      case CompassPoint.southWest:
        return '西南方代表愛情與婚姻，適合增進感情';
      case CompassPoint.west:
        return '西方代表子女與創造力，適合開展新事物';
      case CompassPoint.northWest:
        return '西北方代表貴人與助力，適合尋求支持';
    }
  }

  static List<String> getAuspiciousActivities(CompassPoint direction) {
    switch (direction) {
      case CompassPoint.north:
        return ['求職', '升遷', '考試'];
      case CompassPoint.northEast:
        return ['讀書', '進修', '研究'];
      case CompassPoint.east:
        return ['運動', '養生', '治療'];
      case CompassPoint.southEast:
        return ['投資', '開業', '談判'];
      case CompassPoint.south:
        return ['社交', '演講', '表演'];
      case CompassPoint.southWest:
        return ['約會', '婚禮', '修繕'];
      case CompassPoint.west:
        return ['創作', '藝術', '娛樂'];
      case CompassPoint.northWest:
        return ['會友', '求助', '合作'];
    }
  }
} 