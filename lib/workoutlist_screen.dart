import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/workout.dart';
import '../providers/exercises_provider.dart';
import '../providers/sets_provider.dart';
import '../providers/workouts_provider.dart';
import 'components/delete_workout_dialog.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({super.key});

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  List<Workout> workouts = [];
  List<Exercise> exercises = [];
  int? selectedWorkoutIndex;
  Map<String, List<Set>> workoutSets = {}; // Cache for fetched sets

  @override
  void initState() {
    super.initState();
    // Fetch workouts and exercises on init
    final workoutProvider =
        Provider.of<WorkoutsProvider>(context, listen: false);
    final exercisesProvider =
        Provider.of<ExercisesProvider>(context, listen: false);
    workouts = workoutProvider.workouts!; // Fetch workouts
    exercises = exercisesProvider.exercises!; // Fetch exercises
  }

  // Function to fetch sets for a workout
  Future<void> _fetchSetsForWorkout(String workoutId) async {
    final setsProvider = Provider.of<SetsProvider>(context, listen: false);
    setsProvider.fetchSets(workoutId);
    setState(() {
      workoutSets[workoutId] = setsProvider.sets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
      ),
      body: Consumer<WorkoutsProvider>(
        builder: (context, workoutProvider, child) {
          final workouts =
              workoutProvider.workouts; // Fetch workouts from the provider

          if (workouts!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'My Workouts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedWorkoutIndex == index;
                  Workout workout = workouts[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (selectedWorkoutIndex == index) {
                                selectedWorkoutIndex = null;
                              } else {
                                selectedWorkoutIndex = index;
                                _fetchSetsForWorkout(workout.id);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                isSelected ? Colors.yellow : Colors.white,
                            backgroundColor: Colors.black,
                            side: BorderSide(
                                color: isSelected
                                    ? Colors.yellow
                                    : Colors.transparent,
                                width: 2.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                workout.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.yellow,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Exercises:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                ..._buildExerciseList(workout),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Edit button logic
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[900],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.yellow),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete button logic
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return DeleteWorkoutDialog(
                                              workout: workout,
                                              sets: workoutSets[workout.id]!,
                                            );
                                          },
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.grey[900],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }

  List<Widget> _buildExerciseList(Workout workout) {
    List<Exercise> workoutExercises = exercises.where((exercise) {
      return workoutSets[workout.id]
              ?.any((set) => set.exercisesId == exercise.id) ??
          false;
    }).toList();

    workoutExercises.sort((a, b) => a.name.compareTo(b.name));

    return workoutExercises.map((exercise) {
      return ListTile(
        title: Text(exercise.name),
        subtitle: Text(
            'Sets: ${workoutSets[workout.id]?.where((set) => set.exercisesId == exercise.id).length ?? 0}'),
      );
    }).toList();
  }
}
