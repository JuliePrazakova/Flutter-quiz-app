import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

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
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStatistics(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading statistics');
          } else {
            int totalCorrectAnswers = snapshot.data!['totalCorrectAnswers'] - 1;
            if(totalCorrectAnswers == -1){
              totalCorrectAnswers = 0;
            }
            Map<String, int> topicStatistics = snapshot.data!['topicStatistics'];

            QuizService quizService = QuizService();

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: quizService.getTopics(http.Client()),
              builder: (context, topicSnapshot) {
                if (topicSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (topicSnapshot.hasError) {
                  return const Text('Error loading topics');
                } else {
                  List<Map<String, dynamic>> sortedTopics = topicSnapshot.data!;
                  sortedTopics.sort((a, b) => topicStatistics[b['name']]!.compareTo(topicStatistics[a['name']]!));

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total Correct Answers: $totalCorrectAnswers'),
                        Column(
                          children: sortedTopics
                              .map((topic) =>
                                  Text('${topic['name']}: ${topicStatistics[topic['name']]} correct answers'))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadStatistics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalCorrectAnswers = prefs.getInt('totalCorrectAnswers') ?? 0;
    Map<String, int> topicStatistics = {};

    QuizService quizService = QuizService();
    // Load topic-specific statistics
    for (Map<String, dynamic> topic in await quizService.getTopics(http.Client())) {
      String topicName = topic['name'];
      int correctAnswersForTopic = prefs.getInt('topic_$topicName') ?? 0;
      topicStatistics[topicName] = correctAnswersForTopic;
    }

    return {'totalCorrectAnswers': totalCorrectAnswers, 'topicStatistics': topicStatistics};
  }
}
