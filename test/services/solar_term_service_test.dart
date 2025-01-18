import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/services/solar_term_service.dart';
import 'package:all_lucky/core/models/solar_term.dart';

void main() {
  late SolarTermService solarTermService;
  final today = DateTime.now();

  setUp(() {
    solarTermService = SolarTermService();
  });

  group('節氣服務測試', () {
    test('獲取下一個節氣', () async {
      final nextTerm = await solarTermService.getNextTerm(today);
      
      expect(nextTerm, isNotNull);
      expect(nextTerm!.date.isAfter(today), isTrue);
      expect(nextTerm.name, isNotEmpty);
      expect(nextTerm.description, isNotNull);
    });

    test('獲取多個節氣', () async {
      final terms = await solarTermService.getNextTerms(today, limit: 3);
      
      expect(terms.length, equals(3));
      expect(terms.first.date.isAfter(today), isTrue);
      expect(terms.last.date.isAfter(terms.first.date), isTrue);
    });

    test('獲取日期範圍內的節氣', () async {
      final start = today;
      final end = today.add(const Duration(days: 60));
      final terms = await solarTermService.getTermsInRange(start, end);
      
      for (final term in terms) {
        expect(term.date.isAfter(start), isTrue);
        expect(term.date.isBefore(end), isTrue);
      }
    });

    test('空日期範圍應返回空列表', () async {
      final start = today;
      final end = today.subtract(const Duration(days: 1)); // 結束日期在開始日期之前
      final terms = await solarTermService.getTermsInRange(start, end);
      
      expect(terms, isEmpty);
    });

    test('節氣數據格式正確', () async {
      final terms = await solarTermService.getNextTerms(today);
      
      for (final term in terms) {
        expect(term.name, isNotEmpty);
        expect(term.date, isNotNull);
        expect(term.description, isNotNull);
      }
    });
  });
} 