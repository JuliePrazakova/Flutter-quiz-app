import './screens/home_screen.dart';
import './screens/question_screen.dart';
import './screens/statistics_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => HomeScreen(),
  '/question': (context) => QuestionScreen(),
  '/statistics': (context) => StatisticsScreen(),
};
