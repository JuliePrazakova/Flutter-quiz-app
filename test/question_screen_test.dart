import 'package:Quiz_app/screens/question_screen.dart';
import 'package:Quiz_app/services/quiz_service.dart';
import 'package:Quiz_app/widgets/question_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MockQuizService extends Mock implements QuizService {}

void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
    SharedPreferences.setMockInitialValues({});
  });

   testWidgets("Display QuestionScreen with Title and 2 Icon Buttons", (WidgetTester tester) async {
        Map<String, dynamic> topic = {"id": 1, "name": "Basic arithmetics", "question_path": "/topics/1/questions"};

        final app = MaterialApp(
          home: QuestionScreen(topic: topic),
        );

        await tester.pumpWidget(app);

        expect(find.text('Quiz App'), findsOneWidget);

        expect(find.byIcon(Icons.home), findsOneWidget);

        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
  });

    testWidgets('Displays question', (tester) async {
       SharedPreferences.setMockInitialValues({
          'isAnswerSubmitted': false,
          'isAnswerCorrect': false,
        });
       nock.get('/topics/1/questions').reply(200, 
          {
            "id": 1,
            "question": "What is the outcome of 10 + 10?",
            "options": ["20", "2", "200", "95"],
            "answer_post_path": "/topics/1/questions/1/answers"
          }
        );
        nock.post("/topics/1/questions/1/answers", {"answer": "20"})
          .reply(200, {"correct": true});

        Map<String, dynamic> topic = {"id": 1, "name": "Basic arithmetics", "question_path": "/topics/1/questions"};
        final quizService = QuizService();

        final client = http.Client();
        final question = await quizService.getQuestion(topic, client);
        expect(question, isA<Map<String, dynamic>>());

        final app = MaterialApp(
          home: QuestionWidget(topic: topic),
        );
        await tester.pumpWidget(app);
        await tester.pump();
        
        tester.state<QuestionWidgetState>(find.byType(QuestionWidget)).updateQuestion(question);
        await tester.pump();
        expect(find.byType(ElevatedButton), findsNWidgets(4));

        final topicFinder = find.text('What is the outcome of 10 + 10?');
        expect(topicFinder, findsOneWidget);

        expect(find.widgetWithText(ElevatedButton, '20'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, '2'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, '200'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, '95'), findsOneWidget);

        await tester.tap(find.text('20'));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isAnswerSubmitted', true);
        prefs.setBool('isAnswerCorrect', true);

        await tester.pumpAndSettle();
        await tester.pump();


        final textFinder = find.text('Your answer was correct');
        expect(textFinder, findsOneWidget);

        expect(find.widgetWithText(ElevatedButton, 'Move to the next question'), findsOneWidget);
      });      
}
