import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ready_workout_provider.dart';
import 'components/grey_container.dart';
import 'models/ready_workout.dart'; // Assuming GreyContainer or CustomContainer exists

enum TimeFrame { thisWeek, thisMonth, thisYear }

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.thisWeek;
  DateTime _currentDate = DateTime.now();

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

  void _previousTimeFrame() {
    setState(() {
      if (_selectedTimeFrame == TimeFrame.thisWeek) {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      } else if (_selectedTimeFrame == TimeFrame.thisYear) {
        _currentDate = DateTime(_currentDate.year - 1);
      }
    });
  }

  void _nextTimeFrame() {
    setState(() {
      if (_selectedTimeFrame == TimeFrame.thisWeek) {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else if (_selectedTimeFrame == TimeFrame.thisMonth) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      } else if (_selectedTimeFrame == TimeFrame.thisYear) {
        _currentDate = DateTime(_currentDate.year + 1);
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
        title: const Text('Workout Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousTimeFrame,
                ),
                DropdownButton<TimeFrame>(
                  value: _selectedTimeFrame,
                  items: const [
                    DropdownMenuItem(
                      value: TimeFrame.thisWeek,
                      child: Text('This Week'),
                    ),
                    DropdownMenuItem(
                      value: TimeFrame.thisMonth,
                      child: Text('This Month'),
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
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextTimeFrame,
                ),
              ],
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
