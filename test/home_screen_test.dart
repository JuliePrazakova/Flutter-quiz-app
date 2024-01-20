import 'package:Quiz_app/screens/home_screen.dart';
import 'package:Quiz_app/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';
import 'package:http/http.dart' as http;

import 'fetch_topics_test.mocks.dart';


void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  testWidgets("Display HomeScreen with Title, description and Generic practice button", (WidgetTester tester) async {

   const app = MaterialApp(
          home: HomeScreen(),
    );

    await tester.pumpWidget(app);
    await tester.pump();

    expect(find.text('Quiz App'), findsOneWidget);

    final description = find.text('Welcome to Quiz App! Challenge yourself by selecting a topic below. '
        'Each topic offers a set of questions to test your knowledge. '
        'For an extra challenge, try the "Generic Practice" option. This feature intelligently '
        'selects topics with the fewest correct answers, helping you strengthen your weak areas. '
        'Are you ready to embark on a learning adventure?',
        );
    expect(description, findsOneWidget);
    
    final topicFinder = find.widgetWithText(ElevatedButton,'Generic practice');
    expect(topicFinder, findsOneWidget);
  });

  testWidgets('Display no topics available text', (tester) async {
      nock.get('/topics').reply(200, []);
      final quizService = QuizService();
      final topics = await quizService.getTopics(http.Client());  
      expect(topics, isA<List<Map<String, dynamic>>>());

        const app = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(app);
        await tester.pump();

        // Access the state of HomeScreen and update the topics
        tester.state<HomeScreenState>(find.byType(HomeScreen)).updateTopics(topics);

        await tester.pump();

        final topicFinder = find.widgetWithText(ElevatedButton,'Generic practice');
        expect(topicFinder, findsOneWidget);

        expect(find.text('No topics available'), findsOne);
  });

    testWidgets('Displays topics', (tester) async {
      nock.get('/topics').reply(200, [
        {"id": 1, "name": "Basic arithmetics", "question_path": "/topics/1/questions"},
        {"id": 2, "name": "Countries and capitals", "question_path": "/topics/2/questions"},
        {"id": 3, "name": "Countries and continents", "question_path": "/topics/3/questions"},
        {"id": 4, "name": "Dog breeds", "question_path": "/topics/4/questions"}
      ]);

      final quizService = QuizService();
      final topics = await quizService.getTopics(http.Client());
      expect(topics, isA<List<Map<String, dynamic>>>());

        const app = MaterialApp(
          home: HomeScreen(),
        );

        await tester.pumpWidget(app);
        await tester.pump();

        // Access the state of HomeScreen and update the topics
        tester.state<HomeScreenState>(find.byType(HomeScreen)).updateTopics(topics);

        await tester.pump();

        final topicFinder = find.widgetWithText(ElevatedButton,'Generic practice');
        expect(topicFinder, findsOneWidget);
        expect(find.text('Select a Topic:'), findsOneWidget);

        expect(find.widgetWithText(ElevatedButton, 'Basic arithmetics'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Countries and capitals'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Countries and continents'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Dog breeds'), findsOneWidget);
      });      
}