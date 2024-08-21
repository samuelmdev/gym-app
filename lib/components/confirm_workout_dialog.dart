import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/planned_workout_provider.dart';

class ConfirmWorkoutDialog extends StatefulWidget {
  final String workoutType;
  final int exercisesCount;
  final String?
      existingWorkoutName; // Optional parameter for existing workout name

  const ConfirmWorkoutDialog({
    super.key,
    required this.workoutType,
    required this.exercisesCount,
    this.existingWorkoutName,
  });

  @override
  _ConfirmWorkoutDialogState createState() => _ConfirmWorkoutDialogState();
}

class _ConfirmWorkoutDialogState extends State<ConfirmWorkoutDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController with existingWorkoutName if it exists
    _nameController =
        TextEditingController(text: widget.existingWorkoutName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Workout Plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Workout Type: ${widget.workoutType}'),
          Text('Exercises Count: ${widget.exercisesCount}'),
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
            // Save button functionality here
            final workoutName = _nameController.text.trim();
            if (workoutName.isNotEmpty) {
              // Implement the save functionality here
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
