import './quiz_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class QuizService {
  static SharedPreferences? _prefs;
  static Dio _dio = Dio();

  static Future<List<Map<String, dynamic>>> getTopics() async {
    try {
      Response response = await _dio.get('https://dad-quiz-api.deno.dev/topics');
      List<dynamic> data = response.data;
      List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(data);
      return topics;
    } catch (error) {
      print('Error fetching topics: $error');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getQuestion(Map<String, dynamic> topic) async {
    try {
      String questionPath = topic['question_path'];
      Response response = await _dio.get('https://dad-quiz-api.deno.dev$questionPath');
      Map<String, dynamic> question = response.data;
      return question;
    } catch (error) {
      print('Error fetching question: $error');
      return Future.error('Error fetching question: $error');
    }
  }

  static Future<Map<String, dynamic>> postAnswer(
    String topic,
    int questionId,
    String answer,
  ) async {
    try {
      Response response = await _dio.post(
        'https://dad-quiz-api.deno.dev/topics/$topic/questions/$questionId/answers',
        data: {'answer': answer},
      );
      Map<String, dynamic> responseData = response.data;

      if (responseData['correct'] == true) {
        _prefs ??= await SharedPreferences.getInstance();
        bool hasUserAttempted = _prefs!.getBool('hasUserAttempted') ?? false;

        if (!hasUserAttempted) {
          incrementTotalCorrectAnswers();
          _prefs!.setBool('hasUserAttempted', true);
        }
      }

      return responseData;
    } catch (error) {
      print('Error posting answer: $error');
      return {}; // Return an empty map or handle the error as needed
    }
  }


  static Future<int> getTotalCorrectAnswers() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getInt('totalCorrectAnswers') ?? 0;
    } catch (error) {
      print('Error getting total correct answers: $error');
      return 0;
    }
  }

  static Future<void> incrementTotalCorrectAnswers() async {
    _prefs ??= await SharedPreferences.getInstance();
    int currentTotal = _prefs!.getInt('totalCorrectAnswers') ?? 0;
    _prefs!.setInt('totalCorrectAnswers', currentTotal + 1);
  }
  
  static Future<int?> getTopicId(String topicName) async {
    try {
      List<Map<String, dynamic>> topics = await getTopics();
      print('All topics: $topics');
      
      int topicIndex = topics.indexWhere((topic) => topic['name'] == topicName);
      if (topicIndex != -1) {
        return topics[topicIndex]['id'];
      } else {
        print('Error: Topic not found for topic $topicName');
        throw 'Topic not found';
      }
    } catch (error) {
      print('Error getting topic ID: $error');
      return null;
    }
  }
}
