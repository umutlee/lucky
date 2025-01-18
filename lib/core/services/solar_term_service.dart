import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solar_term.dart';
import '../utils/logger.dart';

class SolarTermService {
  static final SolarTermService _instance = SolarTermService._internal();
  factory SolarTermService() => _instance;
  SolarTermService._internal();

  final _logger = Logger('SolarTermService');
  final _baseUrl = 'https://api.example.com/v1'; // TODO: 替換為實際的API地址

  Future<List<SolarTerm>> getNextTerms(DateTime from, {int limit = 5}) async {
    try {
      _logger.info('獲取從 $from 開始的下 $limit 個節氣');

      // TODO: 替換為實際的API調用
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/solar-terms?from=${from.toIso8601String()}&limit=$limit'),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => SolarTerm.fromJson(json)).toList();
      // }

      // 臨時返回模擬數據
      return [
        SolarTerm(
          name: '立春',
          date: from.add(const Duration(days: 7)),
          description: '春季的第一個節氣，象徵著新的一年開始',
        ),
        SolarTerm(
          name: '雨水',
          date: from.add(const Duration(days: 22)),
          description: '雨量漸增，氣溫回升',
        ),
        SolarTerm(
          name: '驚蟄',
          date: from.add(const Duration(days: 37)),
          description: '春雷始鳴，萬物復蘇',
        ),
        SolarTerm(
          name: '春分',
          date: from.add(const Duration(days: 52)),
          description: '晝夜平分，陰陽相等',
        ),
        SolarTerm(
          name: '清明',
          date: from.add(const Duration(days: 67)),
          description: '天氣清爽明朗，適合掃墓祭祖',
        ),
      ];
    } catch (e) {
      _logger.error('獲取節氣數據失敗: $e');
      rethrow;
    }
  }

  Future<SolarTerm?> getNextTerm(DateTime from) async {
    final terms = await getNextTerms(from, limit: 1);
    return terms.isNotEmpty ? terms.first : null;
  }

  Future<List<SolarTerm>> getTermsInRange(DateTime start, DateTime end) async {
    try {
      _logger.info('獲取 $start 到 $end 之間的節氣');

      // TODO: 替換為實際的API調用
      // final response = await http.get(
      //   Uri.parse(
      //     '$_baseUrl/solar-terms/range?'
      //     'start=${start.toIso8601String()}&'
      //     'end=${end.toIso8601String()}',
      //   ),
      // );
      // 
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => SolarTerm.fromJson(json)).toList();
      // }

      // 臨時返回模擬數據
      final allTerms = await getNextTerms(start);
      return allTerms.where((term) => 
        term.date.isAfter(start) && term.date.isBefore(end)
      ).toList();
    } catch (e) {
      _logger.error('獲取節氣範圍數據失敗: $e');
      rethrow;
    }
  }
} 