import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';
import '../providers/planned_workout_provider.dart';

class ConfirmWorkoutDialog extends StatefulWidget {
  const ConfirmWorkoutDialog({super.key});

  @override
  _ConfirmWorkoutDialogState createState() => _ConfirmWorkoutDialogState();
}

class _ConfirmWorkoutDialogState extends State<ConfirmWorkoutDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final plannedWorkoutProvider =
        Provider.of<PlannedWorkoutProvider>(context, listen: false);
    // Initialize the TextEditingController with the workout name from the provider
    _nameController = TextEditingController(
        text: plannedWorkoutProvider.plannedWorkout?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plannedWorkoutProvider = Provider.of<PlannedWorkoutProvider>(context);

    return AlertDialog(
      title: const Text('Confirm Workout Plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'Workout Type: ${plannedWorkoutProvider.plannedWorkout?.type ?? 'Unknown'}'),
          Text(
              'Exercises Count: ${plannedWorkoutProvider.selectedExercises.length}'),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workout Name',
              hintText: 'Enter a descriptive name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.yellow,
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.yellow,
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            String workoutName = _nameController.text.trim();
            if (workoutName.isNotEmpty) {
              // Update the workout name in the provider
              plannedWorkoutProvider.plannedWorkout?.name = workoutName;

              if (plannedWorkoutProvider.plannedWorkout!.id.isEmpty) {
                // If the workout already has an ID, it means we're editing an existing workout
                plannedWorkoutProvider.updateExistingWorkout();
              } else {
                // Otherwise, we're creating a new workout
                plannedWorkoutProvider.saveNewWorkout();
              }
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (Route<dynamic> route) => false);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
