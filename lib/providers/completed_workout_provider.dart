import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../models/completed_workout.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/set.dart';

class CompletedWorkoutProvider extends ChangeNotifier {
  CompletedWorkout _completedWorkout =
      CompletedWorkout(weightLifted: 0, bodyweightReps: 0, doneSets: 0);

  CompletedWorkout get completedWorkout => _completedWorkout;

  void startWorkout(String userId, Workout? workout) {
    _completedWorkout = CompletedWorkout(
      userId: userId,
      workout: workout,
      exercises: [],
      sets: [],
      workoutEdited: false,
      startTimestamp: TemporalTimestamp(DateTime.now()),
      stopTimestamp: TemporalTimestamp(DateTime
          .now()), // Initialize with the same value, will be updated later
      duration: null, // Placeholder, calculate the duration later
      weightLifted: 0, // Initialize with 0, calculate based on actual data
      bodyweightReps: 0, // Initialize with 0, calculate based on actual data
      doneSets: 0,
    );
    notifyListeners();
  }

  void addExercise(Exercise exercise) {
    _completedWorkout.exercises!.add(exercise);
    notifyListeners();
  }

  void addSet(Exercise exercise, Set set) {
    _completedWorkout.sets!.add(set);

    var weights = set.weight ?? [];

    _completedWorkout.weightLifted += weights[0];
    _completedWorkout.doneSets += 1;
    if (exercise.type == 'Bodyweight') {
      _completedWorkout.bodyweightReps += set.reps[0];
    }

    notifyListeners();
  }

  void completeWorkout() {
    _completedWorkout.stopTimestamp = TemporalTimestamp(DateTime.now());
    // Calculate duration, weightLifted, bodyweightReps here if needed

    notifyListeners();
  }
}
