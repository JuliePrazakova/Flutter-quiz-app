import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';
import 'dart:math';
import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  SharedPreferences? _prefs; 
  List<Map<String, dynamic>> _topics = [];
  late String _buttonText;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _loadTopics();
    _isGenericOn();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

   void _isGenericOn() {
    bool isGenericOn = _prefs?.getBool('isGenericOn') ?? false;
    if(isGenericOn){
      setState(() {
        _buttonText = "Turn off generic practice";
      });
    } else{
      setState(() {
        _buttonText = "Generic practice";
      });
    }
  }

  void updateTopics(List<Map<String, dynamic>> newTopics) {
    setState(() {
      _topics = newTopics;
    });
  }

   Future<void> _loadTopics() async {
    try {
      QuizService quizService = QuizService();

      List<Map<String, dynamic>> topics = await quizService.getTopics(http.Client());
      setState(() {
        _topics = topics;
      });
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7, // Adjust the width as needed
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius for rounded corners
                    ),
                    child: const Text(
                      'Welcome to Quiz App! Challenge yourself by selecting a topic below. '
                      'Each topic offers a set of questions to test your knowledge. '
                      'For an extra challenge, try the "Generic Practice" option. This feature intelligently '
                      'selects topics with the fewest correct answers, helping you strengthen your weak areas. '
                      'Are you ready to embark on a learning adventure?',
                      style: TextStyle(
                        fontSize: 16.0, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  FutureBuilder<bool>(
                    future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('isGenericOn') ?? false),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return ElevatedButton(
                          onPressed: () {
                            _practiceNotGoodTopics(context);
                          },
                          child: Text(_buttonText),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40.0),
                  _buildTopicList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTopicList() {
    if (_topics.isEmpty) {
      return const Text('No topics available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Topic:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        ListView.separated(
          shrinkWrap: true,
          itemCount: _topics.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          itemBuilder: (context, index) {
            String topicName = _topics[index]['name'];
            return ElevatedButton(
              onPressed: () {
                _navigateToQuestionPage(_topics[index]);
              },
              child: Text(topicName),
            );
          },
        ),
      ],
    );
  }
  void _navigateToQuestionPage(Map<String, dynamic> topic) {
    Navigator.pushNamed(
      context,
      '/question',
      arguments: {'topic': topic},
    );
  }

  Map<String, dynamic> _findLeastKnownTopic(List<Map<String, dynamic>> topics) {
    List<Map<String, dynamic>> leastKnownTopics = [];
    double minCorrectAnswers = double.infinity;

    for (var topic in topics) {
      String topicName = topic['name'];
      int correctAnswers = _prefs?.getInt('topic_$topicName') ?? 0;

      if (correctAnswers < minCorrectAnswers) {
        minCorrectAnswers = correctAnswers.toDouble();
        leastKnownTopics = [topic];
      } else if (correctAnswers == minCorrectAnswers) {
        leastKnownTopics.add(topic);
      }
    }

    final random = Random();
    int randomIndex = random.nextInt(leastKnownTopics.length);

    return leastKnownTopics[randomIndex];
  }

  void _practiceNotGoodTopics(BuildContext context) async {
    bool isGenericOn = _prefs?.getBool('isGenericOn') ?? false;

    if (isGenericOn) {
      await _prefs?.setBool('isGenericOn', false);
      setState(() {
        _buttonText = "Generic practice";
      });
    } else {
      await _prefs?.setBool('isGenericOn', true);
      setState(() {
        _buttonText = "Turn off generic practice";
      });
      QuizService quizService = QuizService();

      List<Map<String, dynamic>> topics = await quizService.getTopics(http.Client());
      Map<String, dynamic> foundTopic = _findLeastKnownTopic(topics);

      _navigateToQuestionPage(foundTopic);
    }
  }
}
