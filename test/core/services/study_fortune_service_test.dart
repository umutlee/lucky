import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/study_fortune_service.dart';
import 'package:all_lucky/core/models/user_settings.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'study_fortune_service_test.mocks.dart';

@GenerateMocks([UserSettings])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late StudyFortuneService studyFortuneService;
  late MockUserSettings mockUserSettings;

  setUp(() {
    mockUserSettings = MockUserSettings();
    studyFortuneService = StudyFortuneService();
    when(mockUserSettings.zodiac).thenReturn(Zodiac.rabbit);
  });

  group('StudyFortuneService', () {
    test('generateStudyFortune returns valid StudyFortune', () async {
      final fortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      expect(fortune.overallScore, greaterThanOrEqualTo(0));
      expect(fortune.overallScore, lessThanOrEqualTo(100));
      expect(fortune.efficiencyScore, greaterThanOrEqualTo(0));
      expect(fortune.efficiencyScore, lessThanOrEqualTo(100));
      expect(fortune.memoryScore, greaterThanOrEqualTo(0));
      expect(fortune.memoryScore, lessThanOrEqualTo(100));
      expect(fortune.examScore, greaterThanOrEqualTo(0));
      expect(fortune.examScore, lessThanOrEqualTo(100));
      expect(fortune.bestStudyHours, isNotEmpty);
      expect(fortune.suitableSubjects, isNotEmpty);
      expect(fortune.studyTips, isNotEmpty);
      expect(fortune.description, isNotEmpty);
    });

    test('scores are adjusted based on zodiac sign', () async {
      final rabbitFortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      when(mockUserSettings.zodiac).thenReturn(Zodiac.tiger);
      final tigerFortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      expect(rabbitFortune.overallScore, isNot(equals(tigerFortune.overallScore)));
    });

    test('bestStudyHours should return valid time ranges', () async {
      final fortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      for (final timeRange in fortune.bestStudyHours) {
        expect(timeRange, matches(r'^\d{1,2}:\d{2}-\d{1,2}:\d{2}$'));
      }
    });

    test('suitableSubjects should return appropriate subjects', () async {
      final fortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      expect(fortune.suitableSubjects, isNotEmpty);
      expect(fortune.suitableSubjects.length, inInclusiveRange(3, 5));
      
      for (final subject in fortune.suitableSubjects) {
        expect(subject, isNotEmpty);
      }
    });

    test('studyTips should provide appropriate tips', () async {
      final fortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      expect(fortune.studyTips, hasLength(3));
      
      for (final tip in fortune.studyTips) {
        expect(tip, isNotEmpty);
      }
    });

    test('description should reflect fortune level', () async {
      final fortune = await studyFortuneService.generateStudyFortune(mockUserSettings);
      
      expect(fortune.description, isNotEmpty);
      expect(
        fortune.description,
        anyOf(
          contains('非常好'),
          contains('不錯'),
          contains('平平')
        ),
      );
    });
  });
} 