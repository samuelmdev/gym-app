import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import '../models/completed_workout.dart';
import '../ready_workout_screen.dart'; // Import the screen you want to navigate to

class EndWorkoutModal extends StatelessWidget {
  final CompletedWorkout completedWorkout;
  final int remainingExercises;

  const EndWorkoutModal({
    super.key,
    required this.completedWorkout,
    required this.remainingExercises,
  });

  void endWorkout(BuildContext context, CompletedWorkout completedWorkout) {
    completedWorkout.stopTimestamp = TemporalTimestamp(DateTime.now());
    var difference = completedWorkout.stopTimestamp!.toSeconds() -
        completedWorkout.startTimestamp!.toSeconds();
    completedWorkout.duration = Duration(seconds: difference);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadyWorkoutScreen(
          completedWorkout: completedWorkout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incomplete workout'),
      content: Text('You have $remainingExercises exercises left.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Continue'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: const Text('End Workout'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            endWorkout(
                context, completedWorkout); // Call the endWorkout function
          },
        ),
      ],
    );
  }
}
