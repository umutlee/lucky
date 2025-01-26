import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/services/zodiac_fortune_service.dart';

class MockZodiacFortuneService extends Mock implements ZodiacFortuneService {}

void main() {
  late MockZodiacFortuneService service;

  setUp(() {
    service = MockZodiacFortuneService();
  });

  group('ZodiacFortuneService', () {
    test('calculateZodiacAffinity returns map with 12 entries', () {
      final result = service.calculateZodiacAffinity(Zodiac.rat);
      expect(result.length, 12);
      expect(result[Zodiac.rat], isNotNull);
    });

    test('generateZodiacRecommendations returns non-empty list', () {
      final result = service.generateZodiacRecommendations(85, FortuneType.daily);
      expect(result, isNotEmpty);
    });

    test('getZodiacFortune throws exception on API failure', () {
      when(service.getZodiacFortune(any, any))
          .thenAnswer((_) => Future.error('API Error'));
      
      expect(
        () => service.getZodiacFortune(Zodiac.rat, FortuneType.daily),
        throwsA(isA<String>()),
      );
    });
  });
} 