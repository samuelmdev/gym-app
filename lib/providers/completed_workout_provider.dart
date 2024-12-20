import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import '../models/completed_workout.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../overview_screen.dart';

class CompletedWorkoutProvider extends ChangeNotifier {
  CompletedWorkout _completedWorkout = CompletedWorkout(
      weightLifted: 0, bodyweightReps: 0, doneSets: 0, totalReps: 0);

  CompletedWorkout get completedWorkout => _completedWorkout;

  // Example method to get workouts for the selected time frame
  List<CompletedWorkout>? getWorkoutsForTimeFrame(
      TimeFrame timeFrame, DateTime currentDate) {
    return null;

    // Logic to filter workouts based on the time frame and currentDate
    // For example, filter workouts for the current week, month, or year.
  }

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
      totalReps: 0,
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

    for (var i = 0; i < set.reps.length; i++) {
      _completedWorkout.weightLifted += weights[i];
      _completedWorkout.doneSets += 1;
      _completedWorkout.totalReps += set.reps[i];
      if (exercise.type == 'Bodyweight') {
        _completedWorkout.bodyweightReps += set.reps[i];
      }
    }

    notifyListeners();
  }

  void completeWorkout() {
    _completedWorkout.stopTimestamp = TemporalTimestamp(DateTime.now());
    // Calculate duration, weightLifted, bodyweightReps here if needed

    notifyListeners();
  }
}
