import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_app/models/set.dart';
import 'providers/completed_workout_provider.dart';
import 'ready_workout_screen.dart';
import 'services/exercises_service.dart';
import 'services/set_service.dart';
import 'models/exercise.dart';
import 'models/workout.dart';
import './set_player.dart';

class WorkoutPlayer extends StatefulWidget {
  final Workout workout;

  const WorkoutPlayer({super.key, required this.workout});

  @override
  _WorkoutPlayerState createState() => _WorkoutPlayerState();
}

class _WorkoutPlayerState extends State<WorkoutPlayer> {
  late Future<List<Set>> futureSets;
  late Future<List<Exercise>> futureExercises;
  Map<String, Exercise> exercisesMap = {};

  @override
  void initState() {
    super.initState();
    futureSets = SetService.listSingleSets(widget.workout.id);
    futureExercises = ExerciseService.fetchExercises();
  }

  Future<bool> _showBackDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End Workout'),
            content: const Text('Do you want to end the workout?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var completedWorkoutProvider =
        Provider.of<CompletedWorkoutProvider>(context);
    var completedWorkout = completedWorkoutProvider.completedWorkout;
    bool isAllExercisesCompleted = false;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool dipPop) async {
        if (!dipPop) {
          final bool shouldPop = await _showBackDialog();
          if (context.mounted && shouldPop) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.workout.name,
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        body: FutureBuilder<List<Exercise>>(
          future: futureExercises,
          builder: (context, exerciseSnapshot) {
            if (exerciseSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (exerciseSnapshot.hasError) {
              return Center(child: Text('Error: ${exerciseSnapshot.error}'));
            } else if (!exerciseSnapshot.hasData ||
                exerciseSnapshot.data!.isEmpty) {
              return const Center(child: Text('No exercises found'));
            } else {
              exercisesMap = {for (var e in exerciseSnapshot.data!) e.id: e};

              return FutureBuilder<List<Set>>(
                future: futureSets,
                builder: (context, setSnapshot) {
                  if (setSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (setSnapshot.hasError) {
                    return Center(child: Text('Error: ${setSnapshot.error}'));
                  } else if (!setSnapshot.hasData ||
                      setSnapshot.data!.isEmpty) {
                    return const Center(child: Text('No sets found'));
                  } else {
                    if (isAllExercisesCompleted =
                        completedWorkout.exercises?.length ==
                            setSnapshot.data!.length) {
                      isAllExercisesCompleted = true;
                    }
                    print('completed sets: ${completedWorkout.sets}');
                    return Column(
                      children: [
                        Text(
                            '${completedWorkout.exercises?.length ?? 0}/${setSnapshot.data!.length} Exercises completed'),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25.0,
                          ),
                          child: LinearProgressIndicator(
                            value: setSnapshot.data!.isNotEmpty
                                ? completedWorkout.exercises!.length /
                                    setSnapshot.data!.length
                                : 0,
                            backgroundColor: Colors.grey[900],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 35, 150, 39)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: setSnapshot.data!.length,
                            itemBuilder: (context, index) {
                              Set set = setSnapshot.data![index];
                              Exercise? exercise =
                                  exercisesMap[set.singleSetExercisesId];
                              bool isCompleted = completedWorkout.exercises
                                      ?.contains(exercise) ??
                                  false;

                              return ListTile(
                                title: ElevatedButton(
                                  onPressed: isCompleted
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SetPlayer(
                                                completedWorkout:
                                                    completedWorkout,
                                                exercise: exercise,
                                                sets: set,
                                              ),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted
                                        ? Colors.green
                                        : Theme.of(context).primaryColor,
                                    disabledForegroundColor:
                                        Colors.green.withOpacity(0.9),
                                    disabledBackgroundColor:
                                        Colors.green.withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // slightly rounded edges
                                    ),
                                  ),
                                  child: Text(
                                    exercise?.name ?? 'Unknown Exercise',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                                subtitle: Text(isCompleted
                                    ? '${completedWorkout.sets!.where((sets) => sets.singleSetExercisesId == set.singleSetExercisesId).toList().length} Sets'
                                    : '${set.reps.length} Sets'),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  side: const BorderSide(
                                      color: Colors.yellow, width: 2.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // slightly rounded edges
                                  ),
                                ),
                                onPressed: () {
                                  // Handle Add exercise action
                                },
                                icon: const Icon(Icons.add_rounded,
                                    color: Colors.yellow),
                                label: const Text(
                                  'Add exercise',
                                  style: TextStyle(color: Colors.yellow),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAllExercisesCompleted
                                      ? Colors.yellow
                                      : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // slightly rounded edges
                                  ),
                                ),
                                onPressed: () {
                                  if (isAllExercisesCompleted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReadyWorkoutScreen(
                                          completedWorkout: completedWorkout,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Handle End Workout action if necessary
                                  }
                                },
                                child: Text(
                                  isAllExercisesCompleted
                                      ? 'Workout ready'
                                      : 'End Workout',
                                  style: TextStyle(
                                      color: isAllExercisesCompleted
                                          ? Colors.black
                                          : Colors.yellow),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
