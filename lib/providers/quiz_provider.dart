import 'package:flutter/foundation.dart';

class QuizProvider with ChangeNotifier {
  String _selectedTopic = '';
  int _totalCorrectAnswers = 0;

  String get selectedTopic => _selectedTopic;
  int get totalCorrectAnswers => _totalCorrectAnswers;

  void setSelectedTopic(String topic) {
    _selectedTopic = topic;
    notifyListeners();
  }

  void incrementTotalCorrectAnswers() {
    _totalCorrectAnswers++;
    notifyListeners();
  }
}
