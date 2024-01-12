import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:first_project/services/quiz_service.dart';

// Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('Quiz Service Tests', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      QuizService.prefs = mockPrefs;
      QuizService.setMockInitialValues({
        'totalCorrectAnswers': 0,
      });
    });

    test('getTotalCorrectAnswers returns correct value', () async {
      when(mockPrefs.getInt('totalCorrectAnswers')).thenReturn(5);
      int totalCorrectAnswers = await QuizService.getTotalCorrectAnswers();
      expect(totalCorrectAnswers, 5);
    });

    test('incrementTotalCorrectAnswers increments correctly', () async {
      when(mockPrefs.getInt('totalCorrectAnswers')).thenReturn(5);
      await QuizService.incrementTotalCorrectAnswers();
      verify(mockPrefs.setInt('totalCorrectAnswers', 6)).called(1);
    });
  });
}
