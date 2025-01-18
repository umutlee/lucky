import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lucky_day.dart';
import '../utils/logger.dart';

class LuckyDayService {
  static final LuckyDayService _instance = LuckyDayService._internal();
  factory LuckyDayService() => _instance;
  LuckyDayService._internal();

  final _logger = Logger('LuckyDayService');
  final _baseUrl = 'https://api.example.com/v1'; // TODO: 替換為實際的API地址

  Future<List<LuckyDay>> getNextLuckyDays(DateTime from, {int limit = 5}) async {
    try {
      _logger.info('獲取從 $from 開始的下 $limit 個吉日');

      // TODO: 替換為實際的API調用
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/lucky-days?from=${from.toIso8601String()}&limit=$limit'),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => LuckyDay.fromJson(json)).toList();
      // }

      // 臨時返回模擬數據
      return [
        LuckyDay(
          date: from.add(const Duration(days: 3)),
          description: '適合求財',
          suitableActivities: ['投資', '開業', '簽約'],
          luckyDirections: ['東', '南'],
          score: 90,
        ),
        LuckyDay(
          date: from.add(const Duration(days: 5)),
          description: '適合考試',
          suitableActivities: ['學習', '考試', '面試'],
          luckyDirections: ['南', '西'],
          score: 85,
        ),
        LuckyDay(
          date: from.add(const Duration(days: 8)),
          description: '適合結婚',
          suitableActivities: ['婚禮', '訂婚', '搬家'],
          luckyDirections: ['東', '南'],
          score: 95,
        ),
        LuckyDay(
          date: from.add(const Duration(days: 12)),
          description: '適合旅行',
          suitableActivities: ['出遊', '探親', '遠行'],
          luckyDirections: ['西', '北'],
          score: 88,
        ),
        LuckyDay(
          date: from.add(const Duration(days: 15)),
          description: '適合開業',
          suitableActivities: ['開業', '簽約', '投資'],
          luckyDirections: ['東', '南'],
          score: 92,
        ),
      ];
    } catch (e) {
      _logger.error('獲取吉日數據失敗: $e');
      rethrow;
    }
  }

  Future<LuckyDay?> getNextLuckyDay(DateTime from) async {
    final luckyDays = await getNextLuckyDays(from, limit: 1);
    return luckyDays.isNotEmpty ? luckyDays.first : null;
  }

  Future<List<LuckyDay>> getLuckyDaysInRange(DateTime start, DateTime end) async {
    try {
      _logger.info('獲取 $start 到 $end 之間的吉日');

      // TODO: 替換為實際的API調用
      // final response = await http.get(
      //   Uri.parse(
      //     '$_baseUrl/lucky-days/range?'
      //     'start=${start.toIso8601String()}&'
      //     'end=${end.toIso8601String()}',
      //   ),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => LuckyDay.fromJson(json)).toList();
      // }

      // 臨時返回模擬數據
      final allLuckyDays = await getNextLuckyDays(start);
      return allLuckyDays.where((day) => 
        day.date.isAfter(start) && day.date.isBefore(end)
      ).toList();
    } catch (e) {
      _logger.error('獲取吉日範圍數據失敗: $e');
      rethrow;
    }
  }

  Future<List<LuckyDay>> getLuckyDaysByActivity(String activity, {DateTime? from}) async {
    try {
      _logger.info('獲取適合 $activity 的吉日');
      from ??= DateTime.now();

      // TODO: 替換為實際的API調用
      // final response = await http.get(
      //   Uri.parse(
      //     '$_baseUrl/lucky-days/activity/$activity?'
      //     'from=${from.toIso8601String()}',
      //   ),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => LuckyDay.fromJson(json)).toList();
      // }

      // 臨時返回模擬數據
      final allLuckyDays = await getNextLuckyDays(from);
      return allLuckyDays.where((day) => 
        day.suitableActivities?.contains(activity) ?? false
      ).toList();
    } catch (e) {
      _logger.error('獲取活動相關吉日失敗: $e');
      rethrow;
    }
  }
} 