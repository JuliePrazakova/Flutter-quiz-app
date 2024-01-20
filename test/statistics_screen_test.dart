import 'package:Quiz_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Quiz_app/services/quiz_service.dart';
import 'package:http/http.dart' as http;


class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
   setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
    SharedPreferences.setMockInitialValues({});
  });

    testWidgets('StatisticsScreen displays correct texts', (WidgetTester tester) async {
        nock.get('/topics').reply(200, [
              {"id": 1, "name": "Basic arithmetics", "question_path": "/topics/1/questions"},
              {"id": 2, "name": "Countries and capitals", "question_path": "/topics/2/questions"},
              {"id": 3, "name": "Countries and continents", "question_path": "/topics/3/questions"},
              {"id": 4, "name": "Dog breeds", "question_path": "/topics/4/questions"}
        ]);

          final SharedPreferences testSharedPreferences = await SharedPreferences.getInstance();
          testSharedPreferences.setInt('totalCorrectAnswers', 10);
          testSharedPreferences.setInt('topic_Basic arithmetics', 5);
          testSharedPreferences.setInt('topic_Countries and capitals', 8);
          testSharedPreferences.setInt('topic_Countries and continents', 8);
          testSharedPreferences.setInt('topic_Dog breeds', 2);

          final quizService = QuizService();
          final topics = await quizService.getTopics(http.Client());
          expect(topics, isA<List<Map<String, dynamic>>>());

          
          const app = MaterialApp(
            home: StatisticsScreen(),
          );
          
          await tester.pumpWidget(app);
          await tester.pumpAndSettle();

          expect(find.text('Quiz App'), findsOneWidget);
          expect(find.byIcon(Icons.home), findsOneWidget);

          expect(find.text('Error loading statistics'), findsNothing);
          expect(testSharedPreferences.getInt('totalCorrectAnswers'), 10);
          expect(testSharedPreferences.getInt('topic_Basic arithmetics'), 5);
          expect(testSharedPreferences.getInt('topic_Countries and capitals'), 8);
          expect(testSharedPreferences.getInt('topic_Countries and continents'), 8);
          expect(testSharedPreferences.getInt('topic_Dog breeds'), 2);

          expect(find.text('Total Correct Answers: 9'), findsOneWidget);

  });

}
