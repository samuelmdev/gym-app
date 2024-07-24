import 'package:flutter/material.dart';
import './models/completed_workout.dart';

class ReadyWorkoutScreen extends StatelessWidget {
  final CompletedWorkout completedWorkout;

  ReadyWorkoutScreen({required this.completedWorkout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout Summary',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Name: ${completedWorkout.workout?.name}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Started at: ${completedWorkout.startTimestamp}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Duration: ${completedWorkout.duration} minutes',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      '${completedWorkout.weightLifted} kg',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Text('Lifted Weight'),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      '${completedWorkout.doneSets}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Text('Sets done'),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      '${completedWorkout.bodyweightReps}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Text('Bodyweight Reps'),
                  ],
                )
              ],
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
