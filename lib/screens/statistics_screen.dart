import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';

class StatisticsScreen extends StatelessWidget {
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
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error loading statistics');
          } else {
            int totalCorrectAnswers = snapshot.data!['totalCorrectAnswers'] - 1;
            if(totalCorrectAnswers == -1){
              totalCorrectAnswers = 0;
            }
            Map<String, int> topicStatistics = snapshot.data!['topicStatistics'];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total Correct Answers: $totalCorrectAnswers'),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: QuizService.getTopics(),
                    builder: (context, topicSnapshot) {
                      if (topicSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (topicSnapshot.hasError) {
                        return Text('Error loading topics');
                      } else {
                        List<String> topicNames = topicSnapshot.data!
                            .map<String>((topic) => topic['name'] as String)
                            .toList();

                        return Column(
                          children: topicNames
                              .map((topicName) =>
                                  Text('$topicName: ${topicStatistics[topicName]} correct answers'))
                              .toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
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

    // Load topic-specific statistics
    for (Map<String, dynamic> topic in await QuizService.getTopics()) {
      String topicName = topic['name'];
      int correctAnswersForTopic = prefs.getInt('topic_$topicName') ?? 0;
      topicStatistics[topicName] = correctAnswersForTopic;
    }

    return {'totalCorrectAnswers': totalCorrectAnswers, 'topicStatistics': topicStatistics};
  }
}
