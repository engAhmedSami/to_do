import 'package:flutter/material.dart';
import '../data/models/event_model.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/signup_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/events/events_list_page.dart';
import '../presentation/pages/events/event_details_page.dart';
import '../presentation/pages/events/add_edit_event_page.dart';
import '../presentation/pages/pomodoro/pomodoro_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/home_page.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String events = '/events';
  static const String eventDetails = '/event_details';
  static const String addEditEvent = '/add_edit_event';
  static const String pomodoro = '/pomodoro';
  static const String dashboard = '/dashboard';

  // Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute<dynamic>(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute<dynamic>(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute<dynamic>(builder: (_) => const HomePage());
      case events:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const EventsListPage(),
        );
      case eventDetails:
        final event = settings.arguments as EventModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EventDetailsPage(event: event),
        );
      case addEditEvent:
        final event = settings.arguments as EventModel?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => AddEditEventPage(event: event),
        );
      case pomodoro:
        return MaterialPageRoute<dynamic>(builder: (_) => const PomodoroPage());
      case dashboard:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const DashboardPage(),
        );
      default:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashPage());
    }
  }
}
