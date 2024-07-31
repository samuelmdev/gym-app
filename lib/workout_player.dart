import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/providers/exercises_provider.dart';
import 'package:gym_app/providers/sets_provider.dart';
import 'package:provider/provider.dart';
import 'package:gym_app/models/set.dart';
import 'components/add_exercise_modal.dart';
import 'providers/completed_workout_provider.dart';
import 'ready_workout_screen.dart';
//import 'services/exercises_service.dart';
//import 'services/set_service.dart';
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
  Map<String, Exercise> exercisesMap = {};
  bool _setsFetched = false;

  @override
  void initState() {
    super.initState();
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
    List<Exercise>? exercises = [];
    List<Set>? sets = [];
    var completedWorkoutProvider =
        Provider.of<CompletedWorkoutProvider>(context);
    var completedWorkout = completedWorkoutProvider.completedWorkout;
    var exercisesProvider = Provider.of<ExercisesProvider>(context);
    exercises = exercisesProvider.exercises;
    var setsProvider = Provider.of<SetsProvider>(context, listen: false);
    if (!_setsFetched) {
      setsProvider.fetchSets(widget.workout.id).then((_) {
        setState(() {
          _setsFetched = true;
        });
      });
    }
    sets = setsProvider.sets;

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
        body: !_setsFetched
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(
                      '${completedWorkout.exercises?.length ?? 0}/${sets.length} Exercises completed'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                    ),
                    child: LinearProgressIndicator(
                      value: sets.isNotEmpty
                          ? completedWorkout.exercises!.length / sets.length
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
                      itemCount: sets.length,
                      itemBuilder: (context, index) {
                        if (exercises!.isNotEmpty) {
                          exercisesMap = {for (var e in exercises) e.id: e};
                        }
                        Set set = sets![index];
                        Exercise? exercise = exercisesMap[set.exercisesId];
                        bool isCompleted =
                            completedWorkout.exercises?.contains(exercise) ??
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
                                          completedWorkout: completedWorkout,
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
                              ? '${completedWorkout.sets!.where((sets) => sets.exercisesId == set.exercisesId).toList().length} Sets'
                              : '${sets[index].reps.length} Sets'),
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
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.7,
                                  child: AddExerciseModal(
                                      workoutId: widget.workout.id),
                                );
                              },
                            ).then((newSet) {
                              if (newSet != null) {
                                // Handle the new set added by the modal
                                setState(() {
                                  setsProvider.addSet(newSet);
                                });
                              }
                            });
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
                            backgroundColor:
                                completedWorkout.exercises?.length ==
                                        sets.length
                                    ? Colors.yellow
                                    : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // slightly rounded edges
                            ),
                          ),
                          onPressed: () {
                            if (completedWorkout.exercises?.length ==
                                sets!.length) {
                              completedWorkout.stopTimestamp =
                                  TemporalTimestamp(DateTime.now());
                              var difference = completedWorkout.stopTimestamp!
                                      .toSeconds() -
                                  completedWorkout.startTimestamp!.toSeconds();
                              completedWorkout.duration =
                                  Duration(seconds: difference);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReadyWorkoutScreen(
                                    completedWorkout: completedWorkout,
                                  ),
                                ),
                              );
                            } else {
                              // Handle End Workout action if necessary
                            }
                          },
                          child: Text(
                            completedWorkout.exercises?.length == sets.length
                                ? 'Workout ready'
                                : 'End Workout',
                            style: TextStyle(
                                color: completedWorkout.exercises?.length ==
                                        sets.length
                                    ? Colors.black
                                    : Colors.yellow),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
