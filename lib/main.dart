import 'package:flutter/material.dart';
import './screens/home_screen.dart';
import './screens/question_screen.dart';
import './screens/statistics_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/question': (context) {
          final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuestionScreen(topic: args['topic']);
        },
        '/statistics': (context) => const StatisticsScreen(),
      },
    );
  }
}
