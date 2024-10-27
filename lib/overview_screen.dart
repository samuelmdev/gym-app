import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ready_workout_provider.dart';
import 'package:intl/intl.dart';
import 'components/grey_container.dart';
import 'models/ready_workout.dart'; // For formatting dates

enum TimeFrame { thisWeek, thisMonth, thisYear }

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.thisWeek;
  DateTime _currentDate = DateTime.now();
  final DateTime _minDate = DateTime.now()
      .subtract(const Duration(days: 182)); // Max half a year back

  // Helper methods for getting start and end of the selected timeframe
  DateTime getStartOfTimeFrame() {
    if (_selectedTimeFrame == TimeFrame.thisWeek) {
      return _currentDate.subtract(
          Duration(days: _currentDate.weekday - 1)); // Start of the week
    } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
      return DateTime(
          _currentDate.year, _currentDate.month, 1); // Start of the month
    } else if (_selectedTimeFrame == TimeFrame.thisYear) {
      return DateTime(_currentDate.year, 1, 1); // Start of the year
    }
    return DateTime.now();
  }

  DateTime getEndOfTimeFrame() {
    if (_selectedTimeFrame == TimeFrame.thisWeek) {
      return _currentDate
          .add(Duration(days: 7 - _currentDate.weekday)); // End of the week
    } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
      return DateTime(
          _currentDate.year, _currentDate.month + 1, 0); // End of the month
    } else if (_selectedTimeFrame == TimeFrame.thisYear) {
      return DateTime(_currentDate.year, 12, 31); // End of the year
    }
    return DateTime.now();
  }

  String getTimeFrameLabel() {
    if (_selectedTimeFrame == TimeFrame.thisWeek) {
      if (_currentDate.isAtSameMomentAs(DateTime.now())) {
        return "This Week";
      } else if (_currentDate
          .isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        return "Last Week";
      } else {
        return "${DateFormat.yMMMd().format(getStartOfTimeFrame())} - ${DateFormat.yMMMd().format(getEndOfTimeFrame())}";
      }
    } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
      if (_currentDate.month == DateTime.now().month) {
        return "This Month";
      } else {
        return DateFormat.MMMM().format(_currentDate); // Show month name
      }
    } else if (_selectedTimeFrame == TimeFrame.thisYear) {
      if (_currentDate.year == DateTime.now().year) {
        return "This Year";
      } else {
        return "${_currentDate.year}";
      }
    }
    return "";
  }

  void _previousTimeFrame() {
    setState(() {
      if (_selectedTimeFrame == TimeFrame.thisWeek) {
        if (_currentDate.subtract(const Duration(days: 7)).isAfter(_minDate)) {
          _currentDate = _currentDate.subtract(const Duration(days: 7));
        }
      } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
        if (_currentDate.subtract(const Duration(days: 30)).isAfter(_minDate)) {
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
        }
      } else if (_selectedTimeFrame == TimeFrame.thisYear) {
        if (_currentDate.year > _minDate.year) {
          _currentDate = DateTime(_currentDate.year - 1);
        }
      }
    });
  }

  void _nextTimeFrame() {
    setState(() {
      if (_selectedTimeFrame == TimeFrame.thisWeek) {
        // Move to the next week, but not beyond the current week
        if (_currentDate
            .add(const Duration(days: 7))
            .isBefore(DateTime.now())) {
          _currentDate = _currentDate.add(const Duration(days: 7));
        }
      } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
        // Move to the next month, but not beyond the current month
        if (_currentDate
            .add(const Duration(days: 30))
            .isBefore(DateTime.now())) {
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
        }
      } else if (_selectedTimeFrame == TimeFrame.thisYear) {
        // Move to the next year, but not beyond the current year
        if (_currentDate.year < DateTime.now().year) {
          _currentDate = DateTime(_currentDate.year + 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final readyWorkoutProvider = Provider.of<ReadyWorkoutProvider>(context);

    // Fetch workouts based on the selected timeframe
    List<ReadyWorkout> readyWorkouts =
        readyWorkoutProvider.getReadyWorkoutsByTimeFrame(
      getStartOfTimeFrame(),
      getEndOfTimeFrame(),
    );

    // Calculate stats for the selected timeframe
    final stats = calculateStats(readyWorkouts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Metrics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Dropdown and navigation arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Left arrow with text
                IconButton(
                  onPressed: _previousTimeFrame,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),

                // Timeframe selection dropdown
                DropdownButton<TimeFrame>(
                  value: _selectedTimeFrame,
                  items: const [
                    DropdownMenuItem(
                      value: TimeFrame.thisWeek,
                      child: Text('Weekly'),
                    ),
                    DropdownMenuItem(
                      value: TimeFrame.thisMonth,
                      child: Text('Monthly'),
                    ),
                    DropdownMenuItem(
                      value: TimeFrame.thisYear,
                      child: Text('This Year'),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTimeFrame = newValue!;
                    });
                  },
                ),
                const SizedBox(width: 16),

                // Right arrow with text (only visible if there is a future timeframe to navigate to)
                _currentDate.isBefore(DateTime.now())
                    ? IconButton(
                        onPressed: _nextTimeFrame,
                        icon: const Icon(Icons.arrow_forward),
                      )
                    : const SizedBox(), // Empty widget if no future timeframe exists
              ],
            ),

            // Display selected timeframe label
            const SizedBox(height: 16),
            Text(
              'Selected Time Frame: ${getTimeFrameLabel()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Display workouts or message when no workouts are available
            readyWorkouts.isEmpty
                ? const Center(
                    child: Text(
                      'No workout data for the selected timeframe',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Text(
                        'Duration: ${stats['duration']} minutes',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomContainer(
                            text1: '${stats['weightLifted']} kg',
                            text2: 'Lifted Weight',
                          ),
                          const SizedBox(width: 10),
                          CustomContainer(
                            text1: '${stats['setsDone']}',
                            text2: 'Sets Done',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomContainer(
                            text1: '${stats['totalReps']}',
                            text2: 'Reps in Total',
                          ),
                          const SizedBox(width: 10),
                          CustomContainer(
                            text1: '${stats['bodyweightReps']}',
                            text2: 'Bodyweight Reps',
                          ),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Function to calculate stats from ready workouts
  Map<String, dynamic> calculateStats(List<ReadyWorkout> workouts) {
    int totalDuration = 0;
    double totalWeightLifted = 0;
    int totalSetsDone = 0;
    int totalReps = 0;
    int totalBodyweightReps = 0;

    for (var workout in workouts) {
      totalDuration += workout.duration?.inMinutes ?? 0;
      totalWeightLifted += workout.weightLifted;
      totalSetsDone += workout.doneSets;
      totalReps += workout.totalReps;
      totalBodyweightReps += workout.bodyweightReps;
    }

    return {
      'duration': totalDuration,
      'weightLifted': totalWeightLifted,
      'setsDone': totalSetsDone,
      'totalReps': totalReps,
      'bodyweightReps': totalBodyweightReps,
    };
  }
}
