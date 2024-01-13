import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

   Future<void> _loadTopics() async {
    try {
      List<Map<String, dynamic>> topics = await QuizService.getTopics();
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
        title: Text('Quiz App'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7, // Adjust the width as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius for rounded corners
                  ),
                  child: Text(
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
                SizedBox(height: 10.0),
                FutureBuilder<bool>(
                  future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('isGenericOn') ?? false),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      bool isGenericOn = snapshot.data ?? false;

                      return ElevatedButton(
                        onPressed: () {
                          _practiceNotGoodTopics(context);
                        },
                        child: Text(_buttonText),
                      );
                    }
                  },
                ),
                 SizedBox(height: 40.0),
                _buildTopicList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTopicList() {
    if (_topics.isEmpty) {
      return Text('No topics available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Topic:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        ListView.separated(
          shrinkWrap: true,
          itemCount: _topics.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.0),
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
      List<Map<String, dynamic>> topics = await QuizService.getTopics();
      Map<String, dynamic> foundTopic = _findLeastKnownTopic(topics);

      Navigator.pushNamed(
        context,
        '/question',
        arguments: {'topic': foundTopic},
      );
    }
  }

   void _navigateToQuestionPage(Map<String, dynamic> topic) {
    Navigator.pushNamed(
      context,
      '/question',
      arguments: {'topic': topic},
    );
  }


  Map<String, dynamic> _findLeastKnownTopic(List<Map<String, dynamic>> topics) {
    Map<String, dynamic> leastKnownTopic = {};
    int searchedNumber = 0;

    while (true) {
      for (var topic in topics) {
        String topicName = topic['name'];
        int correctAnswers = _prefs?.getInt('topic_$topicName') ?? 0;

        if (correctAnswers == searchedNumber) {
          leastKnownTopic = topic;
          return leastKnownTopic; 
        }
      }
      searchedNumber++;
    }
  }
}
