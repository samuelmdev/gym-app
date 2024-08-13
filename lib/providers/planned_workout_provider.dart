import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/workout.dart';

class PlannedWorkoutProvider with ChangeNotifier {
  Workout? _plannedWorkout;
  final List<Exercise> _selectedExercises = [];
  final Map<String, List<Set>> _exerciseSets = {};

  // Getter for selected exercises
  List<Exercise> get selectedExercises => _selectedExercises;

  // Getter for the sets of a specific exercise
  List<Set> getSetsForExercise(String exerciseId) {
    return _exerciseSets[exerciseId] ?? [];
  }

  // Function to initialize a workout plan
  void createPlannedWorkout(String name, String type, String userId) {
    _plannedWorkout = Workout(
        id: UniqueKey().toString(), name: name, type: type, userId: userId);
    _selectedExercises.clear();
    _exerciseSets.clear();
    notifyListeners();
  }

  // Function to add an exercise to the workout plan
  void addExercise(Exercise exercise) {
    if (!_selectedExercises.contains(exercise)) {
      _selectedExercises.add(exercise);
      _exerciseSets[exercise.id] = [];
      notifyListeners();
    }
  }

  // Function to remove an exercise from the workout plan
  void removeExercise(Exercise exercise) {
    _selectedExercises.remove(exercise);
    _exerciseSets.remove(exercise.id);
    notifyListeners();
  }

  // Function to add a set to an exercise
  void addSet(Set set) {
    if (_exerciseSets.containsKey(set.exercisesId)) {
      final setId = UniqueKey().toString();
      final newSet = Set(
          id: setId,
          reps: set.reps,
          weight: set.weight,
          exercisesId: set.exercisesId,
          workoutID: _plannedWorkout?.id);
      _exerciseSets[set.exercisesId]!.add(newSet);
      notifyListeners();
    }
  }

// Function to remove all sets associated with a specific exerciseId
  void removeAllSetsForExercise(String exerciseId) {
    if (_exerciseSets.containsKey(exerciseId)) {
      _exerciseSets[exerciseId]!.clear(); // Clear all sets for the exercise
      notifyListeners();
    }
  }

  // Function to get the planned workout
  Workout? getPlannedWorkout() {
    return _plannedWorkout;
  }

  // Function to save the workout plan
  void savePlannedWorkout() {
    if (_plannedWorkout != null && _selectedExercises.isNotEmpty) {
      // Logic to save the workout and its sets to your database or backend
      // For example, you can use Amplify, Firebase, or any other service.
      // This might involve saving _plannedWorkout and iterating through _exerciseSets to save each set.

      // After saving, you may want to reset the provider
      _plannedWorkout = null;
      _selectedExercises.clear();
      _exerciseSets.clear();
      notifyListeners();
    }
  }
}