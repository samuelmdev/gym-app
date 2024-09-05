import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workouts_provider.dart';
import '../services/workout_service.dart';
import '../services/set_service.dart';
import '../models/workout.dart';
import '../models/set.dart';

class DeleteWorkoutDialog extends StatelessWidget {
  final Workout workout;
  final List<Set> sets; // Pass sets related to this workout

  const DeleteWorkoutDialog(
      {Key? key, required this.workout, required this.sets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Workout'),
      content: Text(
          'Do you want to delete workout "${workout.name}" and all its sets?'),
      actions: [
        // "No" button
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without deleting
          },
          child: const Text('No'),
        ),

        // "Yes" button
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () async {
            try {
              // Delete sets associated with this workout
              for (var set in sets) {
                if (set.workoutID == workout.id) {
                  await SetService.deleteSingleSet(
                      set.id!); // Ensure set.id is not null
                }
              }

              // Call provider to remove the workout
              final workoutProvider =
                  Provider.of<WorkoutsProvider>(context, listen: false);
              workoutProvider.removeWorkout(workout.id);

              // Delete the workout from the database using WorkoutService
              await WorkoutService.deleteWorkout(workout.id);

              // Notify success and close the dialog
              Navigator.of(context).pop();
            } catch (e) {
              debugPrint('Error deleting workout or sets: $e');
              // Handle error (optional: show error message in UI)
            }
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
