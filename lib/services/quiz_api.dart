import 'package:dio/dio.dart';

class QuizApi {
  static Dio _dio = Dio();

  static Future<List<String>> getTopics() async {
    try {
      Response response = await _dio.get('https://dad-quiz-api.deno.dev/topics');
      List<dynamic> data = response.data;
      List<String> topics = data.map((topic) => topic['name'].toString()).toList(); // Explicitly cast to List<String>
      return topics;
    } catch (error) {
      print('Error fetching topics: $error');
      return []; // Return an empty list or handle the error as needed
    }
  }

  static Future<Map<String, dynamic>> getQuestion(int topicId) async {
    try {
      Response response = await _dio.get('https://dad-quiz-api.deno.dev/topics/$topicId/questions');
      Map<String, dynamic> question = response.data;
      return question;
    } catch (error) {
      print('Error fetching question: $error');
      return {}; // Return an empty map or handle the error as needed
    }
  }

  static Future<Map<String, dynamic>> postAnswer(int topicId, int questionId, String answer) async {
    try {
      Response response = await _dio.post('https://dad-quiz-api.deno.dev/topics/$topicId/questions/$questionId/answers', data: {'answer': answer});
      Map<String, dynamic> result = response.data;
      return result;
    } catch (error) {
      print('Error posting answer: $error');
      return {}; // Return an empty map or handle the error as needed
    }
  }
}
