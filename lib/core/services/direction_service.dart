import '../models/compass_direction.dart';

class DirectionService {
  Future<String> getDirectionDescription(CompassPoint direction) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (direction) {
      case CompassPoint.north:
        return '北方為玄武之位，主智慧與謀略，宜靜思考慮，不宜倉促行事。';
      case CompassPoint.northEast:
        return '東北為艮位，為穩健之象，利於謀定而後動，適合長遠規劃。';
      case CompassPoint.east:
        return '東方為青龍之位，代表生機與活力，適合開展新事業，把握機遇。';
      case CompassPoint.southEast:
        return '東南為巽位，主文昌運勢，利於學習、考試、文書工作。';
      case CompassPoint.south:
        return '南方為朱雀之位，象徵光明與機遇，適合社交、談判、展示才能。';
      case CompassPoint.southWest:
        return '西南為坤位，為陰柔之象，宜修身養性，注意健康調養。';
      case CompassPoint.west:
        return '西方為白虎之位，象徵果斷與決策，適合果斷行動，把握時機。';
      case CompassPoint.northWest:
        return '西北為乾位，為剛健之象，有利於開拓進取，實現目標。';
    }
  }

  Future<List<String>> getAuspiciousDirections(CompassPoint direction) async {
    // 模擬網絡請求延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (direction) {
      case CompassPoint.north:
        return ['東北', '西北'];
      case CompassPoint.northEast:
        return ['北', '東'];
      case CompassPoint.east:
        return ['東北', '東南'];
      case CompassPoint.southEast:
        return ['東', '南'];
      case CompassPoint.south:
        return ['東南', '西南'];
      case CompassPoint.southWest:
        return ['南', '西'];
      case CompassPoint.west:
        return ['西南', '西北'];
      case CompassPoint.northWest:
        return ['西', '北'];
    }
  }
} 