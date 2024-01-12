import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_project/main.dart';
import '../lib/screens/home_screen.dart';
import '../lib/screens/question_widget.dart';
import '../lib/screens/statistics_screen.dart';
import 'package:mockito/mockito.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  testWidgets('Opening the application and seeing the list of topics', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 0});

    await tester.pumpWidget(const MyApp());

    expect(find.byType(HomeScreen), findsOneWidget);

    expect(find.text('Basic arithmetics'), findsOneWidget);
    expect(find.text('Countries and capitals'), findsOneWidget);
    expect(find.text('Countries and continents'), findsOneWidget);
    expect(find.text('Dog breeds'), findsOneWidget);

  });

  testWidgets('Selecting a topic and seeing a question for that topic', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 0});

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Basic arithmetics'));
    await tester.pump();

    expect(find.byType(QuestionScreen), findsOneWidget);

    when(mockApiClient.getQuestion('Basic arithmetics')).thenAnswer((_) async {
      return {
        "id": 1,
        "question": "What is the outcome of 3 + 3?",
        "options": ["100", "49", "200", "95", "6"],
        "answer_post_path": "/topics/1/questions/1/answers",
      };
    });

    expect(find.byType(QuestionScreen), findsOneWidget);
    expect(find.text('What is the outcome of'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('Selecting an answer option and verifying correctness', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 0});

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Basic arithmetics'));
    await tester.pump();

    expect(find.byType(QuestionScreen), findsOneWidget);

    when(mockApiClient.getQuestion('Basic arithmetics')).thenAnswer((_) async {
      return {
        "id": 1,
        "question": "What is the outcome of 3 + 3?",
        "options": ["100", "49", "200", "95", "6"],
        "answer_post_path": "/topics/1/questions/1/answers",
      };
    });

    expect(find.byType(QuestionScreen), findsOneWidget);
    expect(find.text('Basic arithmetics'), findsOneWidget);
    expect(find.text('What is the outcome of'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);

    await tester.tap(find.text('95'));
    await tester.pump();

    expect(find.text('Your answer was incorrect'), findsOneWidget);

    await tester.tap(find.text('6'));
    await tester.pump();

    expect(find.text('Your answer was correct'), findsOneWidget);
    expect(find.text('Move to the next question'), findsOneWidget);
  });

  testWidgets('Opening the statistics page and seeing the total correct answer count', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'totalCorrectAnswers': 5});

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pump();

    expect(find.byType(StatisticsScreen), findsOneWidget);

    expect(find.text('Total Correct Answers: 5'), findsOneWidget);
  });

  testWidgets('Opening the statistics page and seeing topic-specific statistics for a topic', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
          'totalCorrectAnswers': 15,
          'topic_Basic arithmetics': 3,
          'topic_Countries and capitals': 5,
          'topic_Countries and continents': 4,
          'topic_Dog breeds': 2,
    });

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Basic arithmetics'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pump();

    expect(find.byType(StatisticsScreen), findsOneWidget);

    expect(find.text('Total Correct Answers: 15'), findsOneWidget);
    expect(find.text('Basic arithmetics: 3 correct answers'), findsOneWidget);
    expect(find.text('Countries and capitals: 5 correct answers'), findsOneWidget);
    expect(find.text('Countries and continents: 4 correct answers'), findsOneWidget);
    expect(find.text('Dog breeds: 2 correct answers'), findsOneWidget);
  });

  testWidgets('Choosing the generic practice option and being shown a question from a topic with the fewest correct answers', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
            'totalCorrectAnswers': 15,
            'topic_Basic arithmetics': 0,
            'topic_Countries and capitals': 5,
            'topic_Countries and continents': 4,
            'topic_Dog breeds': 2,
    });
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Generic Practice'));
    await tester.pump();

    expect(find.byType(QuestionWidget), findsOneWidget);

    expect(find.text('What is the outcome'), findsOneWidget);
    expect(find.text('Basic arithmetics'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
