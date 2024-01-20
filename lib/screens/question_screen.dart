import 'package:flutter/material.dart';
import '../widgets/question_widget.dart';

class QuestionScreen extends StatefulWidget {
  final Map<String, dynamic> topic;

  const QuestionScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter, 
        margin: const EdgeInsets.only(top: 100.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            QuestionWidget(topic: widget.topic),
          ],
        ),
      ),
    );
  }
}
