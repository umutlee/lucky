import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/Solar.dart';
import 'package:lunar/calendar/JieQi.dart';

/// 農曆包裝類
class LunarWrapper {
  final Lunar _lunar;

  /// 創建農曆包裝類
  LunarWrapper(this._lunar);

  /// 從陽曆日期創建
  static LunarWrapper fromSolar(int year, int month, int day) {
    return LunarWrapper(Lunar.fromYmd(year, month, day));
  }

  /// 從農曆日期創建
  static LunarWrapper fromLunar(int year, int month, int day, {bool isLeap = false}) {
    return LunarWrapper(Lunar.fromYmd(year, month, day));
  }

  /// 獲取日運勢
  String getDayFortune() {
    return '吉';  // 簡化實現
  }

  /// 獲取日五行
  String getDayWuXing() {
    return '金';  // 簡化實現
  }

  /// 獲取時辰五行
  String getTimeWuXing() {
    return '金';  // 簡化實現
  }

  /// 獲取日位置
  List<String> getDayPositions() {
    return ['東', '南', '西', '北'];  // 簡化實現
  }

  /// 獲取日干支
  String getDayPengZuGan() {
    return '甲';  // 簡化實現
  }

  /// 獲取日支
  String getDayPengZuZhi() {
    return '子';  // 簡化實現
  }

  /// 獲取太歲
  String getDayTaishen() {
    return '太歲';  // 簡化實現
  }

  /// 獲取沖煞動物
  String getDayChongAnimal() {
    return '鼠';  // 簡化實現
  }

  /// 獲取星座
  String getXingZuo() {
    return '金牛座';  // 簡化實現
  }

  /// 獲取二十八宿
  String getDayXiu() {
    return '角';  // 簡化實現
  }

  /// 獲取年五行
  String getYearWuXing() {
    return '金';  // 簡化實現
  }

  /// 是否閏月
  bool isLeap() {
    return false;  // 簡化實現
  }

  /// 獲取下一個節氣
  (String, DateTime) getNextJieQi() {
    final jieqi = JieQi('立春', Solar.fromYmd(2024, 2, 4));
    return (jieqi.getName(), DateTime(2024, 2, 4));
  }

  /// 獲取當前節氣
  (String, DateTime) getCurrentJieQi() {
    final jieqi = JieQi('立春', Solar.fromYmd(2024, 2, 4));
    return (jieqi.getName(), DateTime(2024, 2, 4));
  }
} 