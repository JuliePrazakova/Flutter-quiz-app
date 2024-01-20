import '../screens/home_screen.dart';
import '../screens/question_screen.dart';
import '../screens/statistics_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const HomeScreen(),
  '/question': (context) => const QuestionScreen(topic: {},),
  '/statistics': (context) => const StatisticsScreen(),
};
