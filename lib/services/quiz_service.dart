import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class QuizService {
  static SharedPreferences? _prefs;
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> getTopics(http.Client client) async {
    try {
      final response = await client.get(Uri.parse('https://dad-quiz-api.deno.dev/topics'));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(json.decode(response.body));
        return topics;      
      } else {
      print('Failed to load topics: ${response.statusCode}');
      return [];
    }
    } catch (error) {
      print('Error fetching topics: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> getQuestion(Map<String, dynamic> topic, http.Client client) async {
    try {
      String questionPath = topic['question_path'];
      final response = await client.get(Uri.parse('https://dad-quiz-api.deno.dev$questionPath'));
     
      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> question = Map<String, dynamic>.from(json.decode(response.body));
        return question;
      } else {
        print('Failed to load question: ${response.statusCode}');
        return Future.error('Failed to load question: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching question: $error');
      return Future.error('Error fetching question: $error');
    }
  }

  Future<Map<String, dynamic>> postAnswer(
    String topicId,
    int questionId,
    String answer,
    http.Client client
  ) async {
    try {
      print('posting ANSWEEEEEEEEEEEEER');
      final response = await client.post(
        Uri.parse('https://dad-quiz-api.deno.dev/topics/$topicId/questions/$questionId/answers'), 
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"answer": answer})); 
        print('ODPOVED PICOOOOOOOO: ${response.body}');

      Map<String, dynamic> responseData = Map<String, dynamic>.from(json.decode(response.body));

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
  
  Future<int?> getTopicId(String topicName) async {
    try {
      List<Map<String, dynamic>> topics = await getTopics(http.Client());
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
