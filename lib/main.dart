import 'package:flutter/material.dart';
import './screens/home_screen.dart';
import './screens/question_screen.dart';
import './screens/statistics_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/question': (context) {
          final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuestionScreen(topic: args['topic']);
        },
        '/statistics': (context) => StatisticsScreen(),
      },
    );
  }
}
