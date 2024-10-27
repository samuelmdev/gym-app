import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/models/date.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'models/ready_workout.dart';
import 'providers/ready_workout_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<DateTime, List<ReadyWorkout>> _groupedWorkouts = {};
  int _selectedWeek = 0; // 0 means current week, -1 is previous week, etc.
  int? _touchedIndex; // For detecting user touches
  String _selectedWeekText = "This Week";

  @override
  void initState() {
    super.initState();
    _loadWorkoutDataForWeek();
  }

  // Load workouts for the selected week
  // Load workouts for the selected week
  void _loadWorkoutDataForWeek() {
    final readyWorkoutProvider =
        Provider.of<ReadyWorkoutProvider>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _selectedWeek * 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Fetch workouts within the selected week, grouped by date
    Map<DateTime, List<ReadyWorkout>> groupedWorkouts =
        readyWorkoutProvider.getReadyWorkoutsByDay(startOfWeek, endOfWeek);

    // Normalize the dates (set time to midnight)
    groupedWorkouts = groupedWorkouts.map((date, workouts) {
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      return MapEntry(normalizedDate, workouts);
    });

    setState(() {
      _groupedWorkouts = groupedWorkouts;
    });
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

    // Initialize volumes for each day of the week (0: Monday, 6: Sunday)
    List<double> volumes = List<double>.filled(7, 0.0);

    _groupedWorkouts.forEach((date, workouts) {
      int dayIndex = date.weekday - 1; // Monday = 1 -> index 0

      double totalVolume = 0;
      for (var workout in workouts) {
        totalVolume += _calculateVolume(workout);
      }

      volumes[dayIndex] = totalVolume; // Set the volume for the specific day
    });

    // Create bar data for each day of the week
    for (int i = 0; i < 7; i++) {
      double barHeight = volumes[i] > 0 ? volumes[i] : 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: barHeight > 0 ? barHeight : 0,
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

  void _handleWeekText() {
    int numOfWeeks(int year) {
      DateTime dec28 = DateTime(year, 12, 28);
      int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
      return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
    }

    /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
    int getWeekNumber(DateTime date) {
      int dayOfYear = int.parse(DateFormat("D").format(date));
      int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
      if (woy < 1) {
        woy = numOfWeeks(date.year - 1);
      } else if (woy > numOfWeeks(date.year)) {
        woy = 1;
      }
      return woy;
    }

    int weekNumber = getWeekNumber(DateTime.now()) + _selectedWeek;
    if (_selectedWeek == 0) {
      setState(() {
        _selectedWeekText = "This Week";
      });
    } else if (_selectedWeek == -1) {
      setState(() {
        _selectedWeekText = "Last Week";
      });
    } else {
      setState(() {
        _selectedWeekText = 'Week $weekNumber';
      });
    }
  }

  // Handling user touch on the bars
  void _handleBarTouch(int index) {
    setState(() {
      _touchedIndex = index;
    });
  }

  // Function to display workout details below the chart
  Widget _displayWorkoutDetails() {
    if (_touchedIndex == null) {
      return const SizedBox.shrink();
    }

    DateTime now = DateTime.now();
    DateTime startOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _selectedWeek * 7));

    DateTime selectedDate = startOfWeek.add(Duration(days: _touchedIndex!));
    selectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (!_groupedWorkouts.containsKey(selectedDate)) {
      return const SizedBox.shrink();
    }

    List<ReadyWorkout> selectedWorkouts = _groupedWorkouts[selectedDate]!;
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    String formattedDate = CustomDateUtils.formatDate(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Details for ${days[_touchedIndex!]},',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ...selectedWorkouts.map((workout) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white),
                    Text('Duration: ${workout.duration ?? 0} minutes',
                        style: const TextStyle(color: Colors.white)),
                    Text('Total Sets: ${workout.doneSets}',
                        style: const TextStyle(color: Colors.white)),
                    Text('Weight Lifted: ${workout.weightLifted} kg',
                        style: const TextStyle(color: Colors.white)),
                    Text('Bodyweight Reps: ${workout.bodyweightReps}',
                        style: const TextStyle(color: Colors.white)),
                    Text('Total Reps: ${workout.totalReps}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                )),
          ],
        ),
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
                  onPressed: _selectedWeek > -10
                      ? () {
                          setState(() {
                            _selectedWeek--;
                            _loadWorkoutDataForWeek();
                            _handleWeekText();
                            _touchedIndex = null;
                          });
                        }
                      : null,
                ),
                Text(
                  _selectedWeekText,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _selectedWeek < 0
                      ? () {
                          setState(() {
                            _selectedWeek++;
                            _loadWorkoutDataForWeek();
                            _handleWeekText();
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
            child: _groupedWorkouts.isEmpty
                ? const Center(
                    child: Text(
                      'No Activity for this week',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Adjust the color if needed
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      barGroups: _getBarChartData(),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false, // Hide top titles
                          ),
                        ),
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
                          setState(() {
                            _touchedIndex =
                                barTouchResponse?.spot?.touchedBarGroupIndex;
                          });
                        },
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          // Display selected workout details in a grey box
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _displayWorkoutDetails(),
            ),
          ),
        ],
      ),
    );
  }
}
