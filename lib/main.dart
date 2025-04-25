import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/routes.dart';
import 'config/themes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/dashboard/dashboard_cubit.dart';
import 'presentation/cubits/events/events_cubit.dart';
import 'presentation/cubits/pomodoro/pomodoro_cubit.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize notification services
  await NotificationService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  AuthCubit(authRepository: AuthRepository())..checkAuth(),
        ),
        BlocProvider(
          create: (context) => EventsCubit(eventRepository: EventRepository()),
        ),
        BlocProvider(create: (context) => PomodoroCubit()),
        BlocProvider(
          create:
              (context) => DashboardCubit(
                dashboardRepository: DashboardRepository(),
                eventRepository: EventRepository(),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Event Countdown',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
