import 'package:flutter/material.dart';
import 'package:gym_app/models/exercise.dart'; // Import your Exercise model
import 'package:gym_app/models/set.dart';
import 'package:provider/provider.dart';
import 'components/add_exercise_modal.dart';
import 'providers/planned_workout_provider.dart';

class SetsPlanner extends StatefulWidget {
  final List<Exercise> selectedExercises;

  const SetsPlanner({super.key, required this.selectedExercises});

  @override
  _SetsPlannerState createState() => _SetsPlannerState();
}

class _SetsPlannerState extends State<SetsPlanner> {
  // Map to store the sets for each exercise
  Map<String, List<Map<String, String>>> exerciseSets = {};

  @override
  void initState() {
    super.initState();
    // Initialize the map with empty sets for each exercise
    for (var exercise in widget.selectedExercises) {
      exerciseSets[exercise.id] = [];
    }
  }

  // Function to add a set for a specific exercise
  void _addSetForExercise(BuildContext context, Exercise exercise) async {
    final newSets = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: AddExerciseModal(
            workoutId: exercise.id,
            exercise: exercise,
          ),
        );
      },
    );

    if (newSets != null) {
      setState(() {
        exerciseSets[exercise.id] = newSets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plannedWorkoutProvider = Provider.of<PlannedWorkoutProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sets planner',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Add sets for exercises',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.selectedExercises[index];
                  final sets =
                      plannedWorkoutProvider.getSetsForExercise(exercise.id);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                side: const BorderSide(color: Colors.yellow),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () async {
                                final newSet = await showModalBottomSheet<Set>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return AddExerciseModal(exercise: exercise);
                                  },
                                );

                                if (newSet != null) {
                                  plannedWorkoutProvider.addSet(newSet);
                                }
                              },
                              child: Text(
                                sets.isEmpty ? 'Add sets' : 'Edit sets',
                                style: const TextStyle(color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        // Display the sets added for this exercise
                        if (sets.isNotEmpty)
                          Column(
                            children: sets.map((set) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${set.reps.length} sets'),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text('No sets added yet'),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add other buttons or actions here if needed
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: plannedWorkoutProvider.selectedExercises.every(
                        (exercise) => plannedWorkoutProvider
                            .getSetsForExercise(exercise.id)
                            .isNotEmpty)
                    ? () {
                        // Confirm workout logic here
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Confirm Workout'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}