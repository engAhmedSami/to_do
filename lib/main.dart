import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';
import 'config/themes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/dashboard/dashboard_cubit.dart';
import 'presentation/cubits/events/events_cubit.dart';
import 'presentation/cubits/pomodoro/pomodoro_cubit.dart';
// Import any additional repositories/cubits needed for Tasks layout
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive for local storage (needed for Event Countdown app)
  await Hive.initFlutter();

  // Initialize notification services
  await NotificationService().init();

  // Check which app layout to use by default
  final prefs = await SharedPreferences.getInstance();
  final isOriginalLayout = prefs.getBool('is_original_layout') ?? true;

  runApp(MyApp(isOriginalLayout: isOriginalLayout));
}

class MyApp extends StatefulWidget {
  final bool isOriginalLayout;

  const MyApp({super.key, required this.isOriginalLayout});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isOriginalLayout;

  @override
  void initState() {
    super.initState();
    _isOriginalLayout = widget.isOriginalLayout;

    // Listen for layout changes
    _listenForLayoutChanges();
  }

  // Set up a listener for layout changes
  void _listenForLayoutChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ValueNotifier<bool> layoutNotifier = ValueNotifier(_isOriginalLayout);
    layoutNotifier.addListener(() {
      final newLayout = layoutNotifier.value;
      if (newLayout != _isOriginalLayout) {
        setState(() {
          _isOriginalLayout = newLayout;
        });
      }
    });

    // Simulate listening for changes in SharedPreferences
    Future.delayed(Duration.zero, () async {
      final newLayout = prefs.getBool('is_original_layout') ?? true;
      layoutNotifier.value = newLayout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Common providers for both layouts
        BlocProvider(
          create:
              (context) =>
                  AuthCubit(authRepository: AuthRepository())..checkAuth(),
        ),
        BlocProvider(
          create: (context) => EventsCubit(eventRepository: EventRepository()),
        ),

        // Original layout providers (conditionally included)
        if (_isOriginalLayout) ...[
          BlocProvider(create: (context) => PomodoroCubit()),
          BlocProvider(
            create:
                (context) => DashboardCubit(
                  dashboardRepository: DashboardRepository(),
                  eventRepository: EventRepository(),
                ),
          ),
        ],

        // New layout providers can be added here
        // if (!_isOriginalLayout) ...[
        //   Add any Task layout specific providers here
        // ],
      ],
      child: ScreenUtilInit(
        child: MaterialApp(
          title: _isOriginalLayout ? 'Event Countdown' : 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          // darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}
