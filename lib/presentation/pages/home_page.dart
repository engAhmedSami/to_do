// // lib/presentation/pages/home_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubits/auth/auth_cubit.dart';
// import '../cubits/auth/auth_state.dart';
// import 'dashboard/dashboard_page.dart';
// import 'events/events_list_page.dart';
// import 'pomodoro/pomodoro_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const EventsListPage(),
//     const PomodoroPage(),
//     const DashboardPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         if (state.status == AuthStatus.unauthenticated) {
//           Navigator.of(
//             context,
//           ).pushNamedAndRemoveUntil('/login', (route) => false);
//         }
//       },
//       child: Scaffold(
//         body: _pages[_selectedIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           selectedItemColor: Theme.of(context).colorScheme.primary,
//           unselectedItemColor: Colors.grey,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
//             BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Pomodoro'),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard),
//               label: 'Dashboard',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
// }
// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import 'calendar/monthly_view_page.dart';
import 'calendar/weekly_view_page.dart';
import 'mailboxes/mailboxes_page.dart';
import 'tasks/tasks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TasksPage(),
    const MailboxesPage(),
    const WeeklyViewPage(),
    const MonthlyViewPage(),
  ];

  final List<String> titles = [
    'Tasks',
    'Mailboxes',
    'Weekly View',
    'Monthly View',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Mailboxes'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_week),
              label: 'Weekly',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Monthly',
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
