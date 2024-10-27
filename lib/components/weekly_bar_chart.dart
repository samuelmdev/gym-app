import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/ready_workout.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<DateTime, List<ReadyWorkout>> groupedWorkouts;

  const WeeklyBarChart({super.key, required this.groupedWorkouts});

  /* Function to generate bar chart data for the current week
  List<BarChartGroupData> _getBarChartData() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < 7; i++) {
      DateTime day = DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(Duration(days: i));
      double totalWorkoutDuration = groupedWorkouts[day]?.fold(0,
              (sum, workout) => sum! + workout.duration!.inMinutes.toInt()) ??
          0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalWorkoutDuration,
              color: totalWorkoutDuration > 0 ? Colors.yellow : Colors.grey,
            ),
          ],
        ),
      );
    }

    return barGroups;
  } */

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

    groupedWorkouts.forEach((date, workouts) {
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
          // showingTooltipIndicators: _touchedIndex == i ? [0] : [],
        ),
      );
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    bool hasWorkouts = groupedWorkouts.isNotEmpty;

    return hasWorkouts
        ? Padding(
            padding: const EdgeInsets.only(top: 20), // Adjust padding if needed
            child: BarChart(
              BarChartData(
                barGroups: _getBarChartData(),
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Text(days[value.toInt()]);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false), // Hide grid
              ),
            ),
          )
        : const Center(
            child: Text(
              'No Activity for this week yet',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
  }
}
