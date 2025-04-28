import 'package:flutter/material.dart';
import '../data/models/event_model.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/signup_page.dart';
import '../presentation/pages/splash/presentation/views/splash_view.dart';
import '../presentation/pages/tasks/tasks_page.dart';
import '../presentation/pages/tasks/edit_task_page.dart';
import '../presentation/pages/tasks/task_detail_page.dart';
import '../presentation/pages/calendar/calendar_page.dart';
import '../presentation/pages/calendar/weekly_view_page.dart';
import '../presentation/pages/calendar/monthly_view_page.dart';
import '../presentation/pages/mailboxes/mailboxes_page.dart';
import '../presentation/pages/home_page.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String editTask = '/edit_task';
  static const String taskDetail = '/task_detail';
  static const String calendar = '/calendar';
  static const String weeklyView = '/weekly_view';
  static const String monthlyView = '/monthly_view';
  static const String mailboxes = '/mailboxes';

  // Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashView());
      case login:
        return MaterialPageRoute<dynamic>(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute<dynamic>(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute<dynamic>(builder: (_) => const HomePage());
      case tasks:
        return MaterialPageRoute<dynamic>(builder: (_) => const TasksPage());
      case editTask:
        final task = settings.arguments as EventModel?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditTaskPage(task: task),
        );
      case taskDetail:
        final task = settings.arguments as EventModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => TaskDetailPage(task: task),
        );
      case calendar:
        return MaterialPageRoute<dynamic>(builder: (_) => const CalendarPage());
      case weeklyView:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const WeeklyViewPage(),
        );
      case monthlyView:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const MonthlyViewPage(),
        );
      case mailboxes:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const MailboxesPage(),
        );
      default:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashView());
    }
  }
}
