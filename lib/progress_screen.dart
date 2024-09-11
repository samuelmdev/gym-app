import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/models/date.dart';
import 'package:gym_app/utils/timestamp_extension.dart';
import 'package:provider/provider.dart';
import 'models/ready_workout.dart';
import 'providers/ready_workout_provider.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedWeek = 0; // 0 means current week, -1 is previous week, etc.
  int? _touchedIndex; // For detecting user touches
  List<ReadyWorkout> _selectedWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutDataForWeek();
  }

  // Load workouts for the selected week
  void _loadWorkoutDataForWeek() {
    final readyWorkoutProvider =
        Provider.of<ReadyWorkoutProvider>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime startOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _selectedWeek * 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Fetch workouts within the selected week
    _selectedWorkouts = readyWorkoutProvider.getReadyWorkoutsByTimeFrame(
        startOfWeek, endOfWeek);
  }

  // Calculate the volume based on workout data
  double _calculateVolume(ReadyWorkout workout) {
    double totalWeight =
        (workout.weightLifted) / 25; // Reduce influence of weight
    double totalSets = workout.doneSets.toDouble();
    double totalReps = workout.totalReps.toDouble();
    double bodyWeightReps = workout.bodyweightReps.toDouble();
    double duration = workout.duration?.inMinutes.toDouble() ?? 0;

    // Sum all data points together for volume, weight has less influence
    return duration + totalSets + totalReps + bodyWeightReps + totalWeight;
  }

  // Get bar chart data
  List<BarChartGroupData> _getBarChartData() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < 7; i++) {
      ReadyWorkout? workoutForDay =
          _selectedWorkouts.length > i ? _selectedWorkouts[i] : null;
      double volume =
          workoutForDay != null ? _calculateVolume(workoutForDay) : 0;

      // Ensure minimum bar height only for days with data
      double barHeight = volume > 0 ? volume : 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: barHeight > 0
                  ? barHeight
                  : 0, // Use bar height, or set to 0 for no data
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8),
              width: 20,
            ),
          ],
          showingTooltipIndicators: _touchedIndex == i ? [0] : [],
        ),
      );
    }

    return barGroups;
  }

  // Handling user touch on the bars
  void _handleBarTouch(int index) {
    setState(() {
      _touchedIndex = index;
    });
  }

  // Function to display workout details below the chart
  Widget _displayWorkoutDetails() {
    if (_touchedIndex == null || _selectedWorkouts.length <= _touchedIndex!) {
      return const SizedBox.shrink();
    }

    ReadyWorkout selectedWorkout = _selectedWorkouts[_touchedIndex!];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    String formattedDate = CustomDateUtils.formatDate(
        selectedWorkout.startTimestamp!.toDateTime());
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Details for ${days[_touchedIndex!]},',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('Duration: ${selectedWorkout.duration ?? 0} minutes',
              style: const TextStyle(color: Colors.white)),
          Text('Total Sets: ${selectedWorkout.doneSets}',
              style: const TextStyle(color: Colors.white)),
          Text('Weight Lifted: ${selectedWorkout.weightLifted} kg',
              style: const TextStyle(color: Colors.white)),
          Text('Bodyweight Reps: ${selectedWorkout.bodyweightReps}',
              style: const TextStyle(color: Colors.white)),
          Text('Total Reps: ${selectedWorkout.totalReps}',
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Activity')),
      body: Column(
        children: [
          // Weekly navigation buttons and dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedWeek--;
                      _loadWorkoutDataForWeek();
                    });
                    setState(() {
                      _touchedIndex = null;
                    });
                  },
                ),
                Text('Week $_selectedWeek'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _selectedWeek < 0
                      ? () {
                          setState(() {
                            _selectedWeek++;
                            _loadWorkoutDataForWeek();
                          });
                          setState(() {
                            _touchedIndex = null;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          // Bar chart showing workout volume
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.4, // 40% of screen height
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                barGroups: _getBarChartData(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(days[value.toInt()]);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false), // Hide grid
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    /* if (!event.isInterestedForInteractions ||
                        barTouchResponse == null) {
                      setState(() {
                        _touchedIndex = null;
                      });
                      return;
                    } */
                    setState(() {
                      _touchedIndex =
                          barTouchResponse?.spot?.touchedBarGroupIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Display selected workout details in a grey box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _displayWorkoutDetails(),
          ),
        ],
      ),
    );
  }
}
