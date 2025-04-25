import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/daily_tracker_model.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../widgets/charts/performance_chart.dart';
import '../../widgets/charts/habit_tracker_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Period selector
          BlocBuilder<DashboardCubit, DashboardState>(
            buildWhen: (previous, current) => previous.period != current.period,
            builder: (context, state) {
              return PopupMenuButton<DashboardPeriod>(
                icon: const Icon(Icons.calendar_today),
                onSelected: (period) {
                  context.read<DashboardCubit>().changePeriod(period);
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: DashboardPeriod.daily,
                        child: Text('Today'),
                      ),
                      const PopupMenuItem(
                        value: DashboardPeriod.weekly,
                        child: Text('This Week'),
                      ),
                      const PopupMenuItem(
                        value: DashboardPeriod.monthly,
                        child: Text('This Month'),
                      ),
                    ],
                initialValue: state.period,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardCubit>().loadDashboard();
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state.status == DashboardStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == DashboardStatus.initial) {
            return const Center(child: Text('Loading dashboard...'));
          }

          if (state.status == DashboardStatus.loading &&
              state.todayTracker == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardCubit>().loadDashboard();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Today's date
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Events progress card
                if (state.todayTracker != null)
                  _buildEventsProgressCard(state.todayTracker!),

                const SizedBox(height: 16),

                // Period selector tabs
                Row(
                  children: [
                    _buildPeriodTab(
                      context,
                      'Daily',
                      state.period == DashboardPeriod.daily,
                      () => context.read<DashboardCubit>().changePeriod(
                        DashboardPeriod.daily,
                      ),
                    ),
                    _buildPeriodTab(
                      context,
                      'Weekly',
                      state.period == DashboardPeriod.weekly,
                      () => context.read<DashboardCubit>().changePeriod(
                        DashboardPeriod.weekly,
                      ),
                    ),
                    _buildPeriodTab(
                      context,
                      'Monthly',
                      state.period == DashboardPeriod.monthly,
                      () => context.read<DashboardCubit>().changePeriod(
                        DashboardPeriod.monthly,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Performance charts
                if (state.periodTrackers.isNotEmpty) ...[
                  PerformanceChart(
                    trackers: state.periodTrackers,
                    title: 'Completed Events',
                    subtitle: 'Track your event completion progress',
                    lineColor: Colors.blue,
                    gradientColor: Colors.blue,
                    valueExtractor:
                        (tracker) => tracker.completedEvents.toDouble(),
                    tooltipFormatter: (value) => '${value.toInt()} events',
                    maxY: _getMaxValue(
                      state.periodTrackers,
                      (tracker) => tracker.completedEvents.toDouble(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PerformanceChart(
                    trackers: state.periodTrackers,
                    title: 'Pomodoro Sessions',
                    subtitle: 'Track your focus time',
                    lineColor: Colors.red,
                    gradientColor: Colors.red,
                    valueExtractor:
                        (tracker) =>
                            tracker.completedPomodoroSessions.toDouble(),
                    tooltipFormatter: (value) => '${value.toInt()} sessions',
                    maxY: _getMaxValue(
                      state.periodTrackers,
                      (tracker) => tracker.completedPomodoroSessions.toDouble(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PerformanceChart(
                    trackers: state.periodTrackers,
                    title: 'Sleep Hours',
                    subtitle: 'Track your sleep duration',
                    lineColor: Colors.purple,
                    gradientColor: Colors.purple,
                    valueExtractor: (tracker) => tracker.sleepHours.toDouble(),
                    tooltipFormatter: (value) => '${value.toInt()} hours',
                    maxY: 12.0,
                  ),
                  const SizedBox(height: 16),
                  HabitTrackerChart(
                    trackers: state.periodTrackers,
                    title: 'Diet Tracking',
                    valueExtractor: (tracker) => tracker.dietTracked,
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                ],

                // Daily tracking section
                if (state.todayTracker != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Daily Tracking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Sleep tracking
                  _buildSleepTracker(state.todayTracker!),
                  const SizedBox(height: 16),

                  // Water intake
                  _buildWaterIntakeTracker(state.todayTracker!),
                  const SizedBox(height: 16),

                  // Diet tracking
                  _buildDietTracker(state.todayTracker!),
                  const SizedBox(height: 16),

                  // Steps tracking
                  _buildStepsTracker(state.todayTracker!),
                  const SizedBox(height: 16),

                  // Tasks section
                  _buildTasksSection(state.todayTracker!),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Build period tab
  Widget _buildPeriodTab(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Build events progress card
  Widget _buildEventsProgressCard(DailyTrackerModel tracker) {
    final hasEvents = tracker.totalEvents > 0;
    final completionPercentage =
        hasEvents
            ? (tracker.completedEvents / tracker.totalEvents * 100).toInt()
            : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Events',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        hasEvents
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: .1)
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$completionPercentage%',
                    style: TextStyle(
                      color:
                          hasEvents
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  hasEvents ? tracker.completedEvents / tracker.totalEvents : 0,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              hasEvents
                  ? '${tracker.completedEvents}/${tracker.totalEvents} events completed'
                  : 'No events scheduled for today',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Build sleep tracker widget
  Widget _buildSleepTracker(DailyTrackerModel tracker) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bedtime, color: Colors.indigo[400]),
                    const SizedBox(width: 8),
                    const Text(
                      'Sleep',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${tracker.sleepHours} hours',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: tracker.sleepHours.toDouble(),
              min: 0,
              max: 12,
              divisions: 12,
              label: '${tracker.sleepHours} hours',
              onChanged: (value) {
                context.read<DashboardCubit>().updateSleepHours(value.toInt());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0h',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  '12h',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build water intake tracker
  Widget _buildWaterIntakeTracker(DailyTrackerModel tracker) {
    // Convert ml to cups (1 cup = 240 ml)
    final cups = (tracker.waterIntake / 240).toStringAsFixed(1);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    const Text(
                      'Water Intake',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$cups cups (${tracker.waterIntake} ml)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                8,
                (index) => GestureDetector(
                  onTap: () {
                    // Each cup is 240ml
                    context.read<DashboardCubit>().updateWaterIntake(
                      (index + 1) * 240,
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          (index + 1) * 240 <= tracker.waterIntake
                              ? Colors.blue[400]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color:
                          (index + 1) * 240 <= tracker.waterIntake
                              ? Colors.white
                              : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build diet tracker
  Widget _buildDietTracker(DailyTrackerModel tracker) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.orange[400]),
                const SizedBox(width: 8),
                const Text(
                  'Diet Tracking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Switch(
              value: tracker.dietTracked,
              onChanged: (value) {
                context.read<DashboardCubit>().toggleDietTracked(value);
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Build steps tracker
  Widget _buildStepsTracker(DailyTrackerModel tracker) {
    // Calculate percentage of daily goal (10,000 steps)
    final percentage = (tracker.steps / 10000).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_walk, color: Colors.green[400]),
                    const SizedBox(width: 8),
                    const Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${tracker.steps} / 10,000',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add 1,000 steps
                    final newSteps = tracker.steps + 1000;
                    context.read<DashboardCubit>().updateSteps(newSteps);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green,
                  ),
                  child: const Text('+1,000'),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Manually enter steps
                    _showStepsInputDialog(context, tracker.steps);
                  },
                  child: const Text('Enter Steps'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build tasks section
  Widget _buildTasksSection(DailyTrackerModel tracker) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, color: Colors.teal[400]),
                const SizedBox(width: 8),
                const Text(
                  'Daily Tasks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      context.read<DashboardCubit>().addCompletedTask(
                        _taskController.text,
                      );
                      _taskController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final task in tracker.completedTasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(task)),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        context.read<DashboardCubit>().removeCompletedTask(
                          task,
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (tracker.completedTasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No tasks added yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show steps input dialog
  void _showStepsInputDialog(BuildContext context, int currentSteps) {
    int steps = currentSteps;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Steps'),
            content: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter number of steps',
              ),
              onChanged: (value) {
                steps = int.tryParse(value) ?? currentSteps;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<DashboardCubit>().updateSteps(steps);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Get maximum value from trackers for chart
  double _getMaxValue(
    List<DailyTrackerModel> trackers,
    double Function(DailyTrackerModel) extractor,
  ) {
    if (trackers.isEmpty) return 10.0;

    double maxValue = 0;
    for (final tracker in trackers) {
      final value = extractor(tracker);
      if (value > maxValue) {
        maxValue = value;
      }
    }

    // Add a little padding to the max value
    return maxValue == 0 ? 10.0 : (maxValue * 1.2).ceilToDouble();
  }
}
