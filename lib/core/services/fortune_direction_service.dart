import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/compass_direction.dart';

final fortuneDirectionProvider = Provider<FortuneDirectionService>((ref) => FortuneDirectionService());

class FortuneDirectionService {
  static const _luckyDirections = [
    CompassDirection.east,
    CompassDirection.south,
    CompassDirection.west,
    CompassDirection.north,
  ];

  static const _unluckyDirections = [
    CompassDirection.northeast,
    CompassDirection.southeast,
    CompassDirection.southwest,
    CompassDirection.northwest,
  ];

  List<CompassDirection> getLuckyDirections() => _luckyDirections;

  List<CompassDirection> getUnluckyDirections() => _unluckyDirections;

  bool isLuckyDirection(CompassDirection direction) {
    return _luckyDirections.any((d) => d.name == direction.name);
  }

  bool isUnluckyDirection(CompassDirection direction) {
    return _unluckyDirections.any((d) => d.name == direction.name);
  }

  String getFullDirectionAdvice(CompassDirection direction) {
    if (isLuckyDirection(direction)) {
      return '當前方位 ${direction.name} 是吉利方位，適合進行重要活動。';
    } else if (isUnluckyDirection(direction)) {
      return '當前方位 ${direction.name} 是不吉利方位，建議避免重要活動。';
    } else {
      return '當前方位 ${direction.name} 是中性方位，可以進行一般活動。';
    }
  }

  String getDirectionSuggestion(CompassDirection direction) {
    if (isLuckyDirection(direction)) {
      return '建議朝向 ${direction.name} 方位行走或坐臥，可以增加運勢。';
    } else if (isUnluckyDirection(direction)) {
      return '建議避免朝向 ${direction.name} 方位行走或坐臥，以免影響運勢。';
    } else {
      return '朝向 ${direction.name} 方位行走或坐臥，對運勢影響不大。';
    }
  }
} 