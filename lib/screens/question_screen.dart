import 'package:flutter/material.dart';
import '../widgets/question_widget.dart';
import '../services/quiz_service.dart';

class QuestionScreen extends StatefulWidget {
  final Map<String, dynamic> topic;

  QuestionScreen({required this.topic});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter, 
        margin: EdgeInsets.only(top: 200.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            Text(
              widget.topic['name'],
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            QuestionWidget(topic: widget.topic),
          ],
        ),
      ),
    );
  }
}
