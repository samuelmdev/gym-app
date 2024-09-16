import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/exercises_provider.dart';
import 'providers/planned_workout_provider.dart';
import 'sets_planner.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  PlannedWorkoutProvider? plannedWorkoutProvider;

  @override
  void initState() {
    super.initState();
    plannedWorkoutProvider =
        Provider.of<PlannedWorkoutProvider>(context, listen: false);

    // Determine if it's a new workout or editing an existing one
    if (plannedWorkoutProvider!.plannedWorkout != null) {
      /* New workout: Initialize an empty workout
      _initializeNewWorkout();
    } else { */
      // Existing workout: Load the data from provider
      _initializePlanner();
    }

    // Handle any specific workout type logic
    _handleWorkoutType();
  }

  Map<String, bool> selectedTypes = {};
  Map<String, bool> selectedTargets = {};
  List<Exercise> filteredExercises = [];
  List<Exercise> selectedExercises = [];
  bool showSelectedExercises = false;
  late String userId;
  String workoutType = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final exercises = Provider.of<ExercisesProvider>(context).exercises;
    userId = ModalRoute.of(context)!.settings.arguments as String;

    // Initialize filters only once after fetching exercises
    if (selectedTypes.isEmpty && selectedTargets.isEmpty) {
      selectedTypes = {
        for (var exercise in exercises!) exercise.type: true,
      };
      selectedTargets = {
        for (var exercise in exercises) exercise.target: true,
      };
      _filterExercises(exercises);
    }
  }

  /// Initializes the screen with the existing data from the provider (for editing)
  void _initializePlanner() {
    // Access the planned workout, selected exercises, and sets from the provider
    final plannedWorkout = plannedWorkoutProvider?.plannedWorkout;
    selectedExercises = plannedWorkoutProvider!.selectedExercises;

    // Update your UI with the existing workout data
    if (plannedWorkout != null) {
      setState(() {
        // Populate your state with the data for editing
        // Example: Updating exercise lists, sets, or other UI components
      });
    }
    _filterExercises(selectedExercises);
  }

  void _filterExercises(List<Exercise> exercises) {
    setState(() {
      filteredExercises = exercises.where((exercise) {
        return selectedTypes[exercise.type]! &&
            selectedTargets[exercise.target]! &&
            !selectedExercises.contains(exercise);
      }).toList();

      // Sort the list alphabetically
      filteredExercises.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _handleWorkoutType() {
    // Recalculate workoutType based on the current selection
    if (selectedExercises.isNotEmpty) {
      final firstExerciseType = selectedExercises.first.type;
      final isMixed =
          selectedExercises.any((ex) => ex.type != firstExerciseType);
      workoutType = isMixed ? 'Mixed' : firstExerciseType;
    } else {
      workoutType = ''; // Reset workoutType if no exercises are selected
    }
  }

  void _toggleExerciseSelection(Exercise exercise) {
    setState(() {
      if (selectedExercises.contains(exercise)) {
        selectedExercises.remove(exercise);
      } else {
        selectedExercises.add(exercise);
      }

      _handleWorkoutType();

      _filterExercises(
        Provider.of<ExercisesProvider>(context, listen: false).exercises!,
      );

      // Automatically toggle back to exercise selection if no exercises are selected
      if (selectedExercises.isEmpty && showSelectedExercises) {
        showSelectedExercises = false;
      }
    });
  }

  void _toggleSelectedView() {
    if (selectedExercises.isNotEmpty) {
      setState(() {
        showSelectedExercises = !showSelectedExercises;
      });
    }
  }

  void _removeSelectedExercise(Exercise exercise) {
    setState(() {
      selectedExercises.remove(exercise);

      _handleWorkoutType();
      _filterExercises(
          Provider.of<ExercisesProvider>(context, listen: false).exercises!);

      // Automatically toggle back to exercise selection if no exercises are selected
      if (selectedExercises.isEmpty && showSelectedExercises) {
        showSelectedExercises = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercises = Provider.of<ExercisesProvider>(context).exercises;
    final plannedWorkoutProvider = Provider.of<PlannedWorkoutProvider>(context);
    print('planner exercises: $exercises');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner - exercises'),
      ),
      body: exercises!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    !showSelectedExercises
                        ? 'Select exercises'
                        : 'Selected exercises',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Text('Workout type: $workoutType'),
                if (!showSelectedExercises) ...[
                  // Filter Section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Type Filters
                        Wrap(
                          spacing: 8.0,
                          children: selectedTypes.keys.map((type) {
                            return FilterChip(
                              label: Text(type),
                              selected: selectedTypes[type]!,
                              selectedColor: Colors.grey[800],
                              backgroundColor: Colors.grey[300],
                              onSelected: (bool value) {
                                setState(() {
                                  selectedTypes[type] = value;
                                  _filterExercises(exercises);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        // Target Filters
                        Wrap(
                          spacing: 8.0,
                          children: selectedTargets.keys.map((target) {
                            return FilterChip(
                              label: Text(target),
                              selected: selectedTargets[target]!,
                              selectedColor: Colors.grey[800],
                              backgroundColor: Colors.grey[300],
                              onSelected: (bool value) {
                                setState(() {
                                  selectedTargets[target] = value;
                                  _filterExercises(exercises);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Exercise List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];

                        return GestureDetector(
                          onTap: () => {
                            _toggleExerciseSelection(exercise),
                            plannedWorkoutProvider.addExercise(exercise),
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 4.0),
                            padding: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: Text(exercise.name),
                              subtitle:
                                  Text('${exercise.type} - ${exercise.target}'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Selected Exercises List
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = selectedExercises[index];

                        return ListTile(
                          title: Text(exercise.name),
                          trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => {
                                    _removeSelectedExercise(exercise),
                                    plannedWorkoutProvider
                                        .removeExercise(exercise),
                                    plannedWorkoutProvider
                                        .removeAllSetsForExercise(exercise.id),
                                  }),
                        );
                      },
                    ),
                  ),
                ],
                // Selected Exercises Count
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: _toggleSelectedView,
                        style: TextButton.styleFrom(
                          backgroundColor: selectedExercises.isNotEmpty
                              ? Colors.black
                              : Colors.grey[900],
                          foregroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 24.0,
                          ),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.yellow),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          showSelectedExercises
                              ? 'Select more'
                              : '${selectedExercises.length} exercises selected',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: selectedExercises.isNotEmpty
                            ? () {
                                plannedWorkoutProvider.createPlannedWorkout(
                                    '', '', workoutType, userId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SetsPlanner(
                                        selectedExercises: selectedExercises),
                                  ),
                                );
                              }
                            : null,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 24.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Confirm exercises',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
