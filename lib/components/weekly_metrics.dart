import 'package:flutter/material.dart';
import './grey_container.dart';

class WeeklyMetrics extends StatelessWidget {
  final Map<String, dynamic> stats;

  const WeeklyMetrics({super.key, required this.stats});
  bool get hasData {
    // Check if all stats are zero
    return stats['duration'] > 0 ||
        stats['weightLifted'] > 0 ||
        stats['setsDone'] > 0 ||
        stats['totalReps'] > 0 ||
        stats['bodyweightReps'] > 0;
  }

  @override
  Widget build(BuildContext context) {
    return hasData ? _buildMetricsContent() : _buildNoMetricsMessage();
  }

  Widget _buildNoMetricsMessage() {
    return const Center(
      child: Text(
        'No Metrics for this week yet',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildMetricsContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
    );
  }
}
