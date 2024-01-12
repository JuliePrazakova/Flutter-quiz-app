import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';

class QuestionWidget extends StatefulWidget {
  final Map<String, dynamic> topic;

  QuestionWidget({required this.topic});

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  Map<String, dynamic>? _questionData;
  bool _isAnswerSubmitted = false;
  bool _isAnswerCorrect = false;
  bool _isFirstAnswer = true;

  SharedPreferences? _prefs; 

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _loadQuestion();
    _loadUserProgress();
  }

  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _loadUserProgress() async {
    _isFirstAnswer = _prefs?.getBool('isFirstAnswer') ?? true;
    _isAnswerCorrect = _prefs?.getBool('isAnswerCorrect') ?? false;
  }

  void _loadQuestion() async {
    setState(() {
        _questionData = null;
        _isAnswerSubmitted = false;
        _isAnswerCorrect = false;
        _isFirstAnswer = true;
      });

    try {
        if (_prefs?.getBool('isGenericOn') == true) {
          List<Map<String, dynamic>> topics = await QuizService.getTopics();
            Map<String, dynamic> leastKnownTopic = {};
            int searchedNumber = 0;
            print(topics);
            while (searchedNumber < 100) {
              bool shouldBreak = false;

              for (var topic in topics) {
                String topicName = topic['name'];
                print(topicName);
                int correctAnswers = _prefs?.getInt('topic_$topicName') ?? 0;

                if (correctAnswers == searchedNumber) {
                  print(searchedNumber);
                  Map<String, dynamic> questionData = await QuizService.getQuestion(topic);
                  print("question data $questionData");
                  setState(() {
                    _questionData = questionData;
                    _prefs?.setBool('isFirstAnswer', true);
                  });
                  shouldBreak = true;
                  break;
                }
                print(searchedNumber);
              }

              if (shouldBreak) {
                break;
              }

              searchedNumber++;
            }      
        } else {
          Map<String, dynamic> questionData = await QuizService.getQuestion(widget.topic);
          setState(() {
            _questionData = questionData;
            _prefs?.setBool('isFirstAnswer', true);
          });
        }
    } catch (error) {
      print('Error loading question: $error');
    }
  }

  void _submitAnswer(String answer) async {
    try {
      Map<String, dynamic> response = await QuizService.postAnswer(
        widget.topic['id'].toString(),
        _questionData!['id'],
        answer,
      );

      setState(() {
        _isAnswerSubmitted = true;
        _isFirstAnswer =  _prefs?.getBool('isFirstAnswer') ?? true;
        _isAnswerCorrect = response['correct'] == true;

        if (_isAnswerCorrect == true) {
          if (_isFirstAnswer == true) {
            int totalCorrectAnswers = _prefs?.getInt('totalCorrectAnswers') ?? 1;
            totalCorrectAnswers++;
            _prefs?.setInt('totalCorrectAnswers', totalCorrectAnswers);

            String topicName = widget.topic['name'];
            int topicCorrectAnswers = _prefs?.getInt('topic_$topicName') ?? 0;
            topicCorrectAnswers++;
            _prefs?.setInt('topic_$topicName', topicCorrectAnswers);
          } else {
            return;
          }
        } else {
          // If the answer is incorrect, set isFirstAnswer to false and stay on the same question.
          _prefs?.setBool('isFirstAnswer', false);
        }

        _prefs?.setBool('isAnswerSubmitted', _isAnswerSubmitted);
        _prefs?.setBool('isAnswerCorrect', _isAnswerCorrect!);

      });
    } catch (error) {
      print('Error submitting answer: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_questionData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(_questionData!['question']),
        ),
        Column(
          children: List.generate(
            _questionData!['options'].length,
            (index) => Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  if (!_isAnswerCorrect) {
                    _submitAnswer(_questionData!['options'][index]);
                  }
                },
                child: Text(_questionData!['options'][index]),
              ),
            ),
          ),
        ),
        if (_isAnswerSubmitted && _isAnswerCorrect == true)
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Your answer was correct'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Allow the user to move to the next question if the answer is correct.
                  _loadQuestion();
                },
                child: Text('Move to the next question'),
              ),
            ],
          ),
        if (_isAnswerSubmitted && _isAnswerCorrect == false)
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Your answer was incorrect'),
          ),
      ],
    );
  }
}