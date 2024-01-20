import 'package:Quiz_app/screens/home_screen.dart';
import 'package:Quiz_app/screens/question_screen.dart';
import 'package:Quiz_app/services/quiz_service.dart';
import 'package:Quiz_app/widgets/question_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'fetch_topics_test.mocks.dart';

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


  // testWidgets('Selecting a topic and seeing a question for that topic', (WidgetTester tester) async {
  //   SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 0});

  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.text('Basic arithmetics'));
  //   await tester.pump();

  //   expect(find.byType(QuestionScreen), findsOneWidget);

  //   when(mockApiClient.getQuestion('Basic arithmetics')).thenAnswer((_) async {
  //     return {
  //       "id": 1,
  //       "question": "What is the outcome of 3 + 3?",
  //       "options": ["100", "49", "200", "95", "6"],
  //       "answer_post_path": "/topics/1/questions/1/answers",
  //     };
  //   });

  //   expect(find.byType(QuestionScreen), findsOneWidget);
  //   expect(find.text('What is the outcome of'), findsOneWidget);
  //   expect(find.byType(ElevatedButton), findsWidgets);
  // });

  // testWidgets('Selecting an answer option and verifying correctness', (WidgetTester tester) async {
  //   SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 0});

  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.text('Basic arithmetics'));
  //   await tester.pump();

  //   expect(find.byType(QuestionScreen), findsOneWidget);

  //   when(mockApiClient.getQuestion('Basic arithmetics')).thenAnswer((_) async {
  //     return {
  //       "id": 1,
  //       "question": "What is the outcome of 3 + 3?",
  //       "options": ["100", "49", "200", "95", "6"],
  //       "answer_post_path": "/topics/1/questions/1/answers",
  //     };
  //   });

  //   expect(find.byType(QuestionScreen), findsOneWidget);
  //   expect(find.text('Basic arithmetics'), findsOneWidget);
  //   expect(find.text('What is the outcome of'), findsOneWidget);
  //   expect(find.byType(ElevatedButton), findsWidgets);

  //   await tester.tap(find.text('95'));
  //   await tester.pump();

  //   expect(find.text('Your answer was incorrect'), findsOneWidget);

  //   await tester.tap(find.text('6'));
  //   await tester.pump();

  //   expect(find.text('Your answer was correct'), findsOneWidget);
  //   expect(find.text('Move to the next question'), findsOneWidget);
  // });

  // testWidgets('Opening the statistics page and seeing the total correct answer count', (WidgetTester tester) async {
  //   SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 5});

  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.byIcon(Icons.bar_chart));
  //   await tester.pump();

  //   expect(find.byType(StatisticsScreen), findsOneWidget);

  //   expect(find.text('Total Correct Answers: 5'), findsOneWidget);
  // });

  // testWidgets('Opening the statistics page and seeing topic-specific statistics for a topic', (WidgetTester tester) async {
  //   SharedPreferences.setMockInitialValues({
  //         'totalCorrectAnswers': 15,
  //         'topic_Basic arithmetics': 3,
  //         'topic_Countries and capitals': 5,
  //         'topic_Countries and continents': 4,
  //         'topic_Dog breeds': 2,
  //   });

  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.text('Basic arithmetics'));
  //   await tester.pump();

  //   await tester.tap(find.byIcon(Icons.bar_chart));
  //   await tester.pump();

  //   expect(find.byType(StatisticsScreen), findsOneWidget);

  //   expect(find.text('Total Correct Answers: 15'), findsOneWidget);
  //   expect(find.text('Basic arithmetics: 3 correct answers'), findsOneWidget);
  //   expect(find.text('Countries and capitals: 5 correct answers'), findsOneWidget);
  //   expect(find.text('Countries and continents: 4 correct answers'), findsOneWidget);
  //   expect(find.text('Dog breeds: 2 correct answers'), findsOneWidget);
  // });

  // testWidgets('Choosing the generic practice option and being shown a question from a topic with the fewest correct answers', (WidgetTester tester) async {
  //   SharedPreferences.setMockInitialValues({
  //           'totalCorrectAnswers': 15,
  //           'topic_Basic arithmetics': 0,
  //           'topic_Countries and capitals': 5,
  //           'topic_Countries and continents': 4,
  //           'topic_Dog breeds': 2,
  //   });
  //   await tester.pumpWidget(const MyApp());

  //   await tester.tap(find.text('Generic Practice'));
  //   await tester.pump();

  //   expect(find.byType(QuestionWidget), findsOneWidget);

  //   expect(find.text('What is the outcome'), findsOneWidget);
  //   expect(find.text('Basic arithmetics'), findsOneWidget);
  //   expect(find.byType(ElevatedButton), findsWidgets);
  // });