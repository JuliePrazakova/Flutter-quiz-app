import 'package:Quiz_app/screens/home_screen.dart';
import 'package:Quiz_app/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart'; 


class MockNavigator extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
    SharedPreferences.setMockInitialValues({});
  });

  // test number 1 
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
          'selects topics with the fewest correct answers and generates its question. After each question it revaluates and chooses again the least succesful one helping you strengthen your weak areas. '
          'Are you ready to embark on a learning adventure?',
        );
    expect(description, findsOneWidget);
    
    final topicFinder = find.widgetWithText(ElevatedButton,'Generic practice');
    expect(topicFinder, findsOneWidget);
  });

// test number 1
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

        tester.state<HomeScreenState>(find.byType(HomeScreen)).updateTopics(topics);

        await tester.pump();

        final topicFinder = find.widgetWithText(ElevatedButton,'Generic practice');
        expect(topicFinder, findsOneWidget);

        expect(find.text('No topics available'), findsOne);
  });

  // test nu ber 1
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

// test number 6
    testWidgets('Test that generic option returns a least known topic', (tester) async {
       final navigatorMock = MockNavigator();
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
        testSharedPreferences.setBool('isGenericOn', false);

        final quizService = QuizService();
        final topics = await quizService.getTopics(http.Client());
        expect(topics, isA<List<Map<String, dynamic>>>());

        final app = MaterialApp(
          home: const HomeScreen(),
          navigatorObservers: [navigatorMock],
        );

        await tester.pumpWidget(app);
        await tester.pump();

        final homeScreenState = tester.state<HomeScreenState>(find.byType(HomeScreen));

        homeScreenState.updateTopics(topics);
        await tester.pump();

        expect(testSharedPreferences.getInt('totalCorrectAnswers'), 10);
        expect(testSharedPreferences.getInt('topic_Basic arithmetics'), 5);
        expect(testSharedPreferences.getInt('topic_Countries and capitals'), 8);
        expect(testSharedPreferences.getInt('topic_Countries and continents'), 8);
        expect(testSharedPreferences.getInt('topic_Dog breeds'), 2);

        await tester.tap(find.widgetWithText(ElevatedButton,'Generic practice'));

        await tester.pumpAndSettle();
        await tester.pump();

        expect(testSharedPreferences.getBool('isGenericOn'), true);
        final foundTopic = homeScreenState.findLeastKnownTopic(topics);
        expect(foundTopic['name'], "Dog breeds");
      });      
}