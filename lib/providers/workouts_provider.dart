import 'package:flutter/material.dart';
import 'package:gym_app/models/workout.dart';

import '../services/workout_service.dart';

class WorkoutsProvider with ChangeNotifier {
  List<Workout>? _workouts;

  final WorkoutService _workoutService = WorkoutService();

  List<Workout>? get workouts => _workouts;

  Future<void> fetchWorkouts(String userId) async {
    try {
      _workouts = await WorkoutService.listWorkouts(userId);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch workouts: $e');
    }
  }

  // Function to add a workout to the list
  Future<void> addWorkout(Workout workout) async {
    _workouts?.add(workout);
    notifyListeners();
  }

  // Function to remove a workout from the list
  Future<void> removeWorkout(String workoutId) async {
    _workouts?.removeWhere((workout) => workout.id == workoutId);
    notifyListeners();
  }

  // Function to create a new workout and add it to the provider's list
  Future<void> createNewWorkout(String name, String type, String userId) async {
    try {
      // Use the service instance to create the workout
      String? newWorkoutId = await WorkoutService.createWorkout(
          name: name, type: type, userId: userId);

      if (newWorkoutId != null) {
        // If the workout is created successfully, add it to the provider's list
        Workout newWorkout = Workout(
          id: newWorkoutId,
          name: name,
          type: type,
          userId: userId,
        );

        addWorkout(newWorkout);
      } else {
        print('Failed to create workout.');
      }
    } catch (e) {
      print('Error creating workout: $e');
    }
  }

  // Function to delete a workout and remove it from the provider's list
  Future<void> deleteExistingWorkout(String workoutId) async {
    try {
      // Use the service instance to delete the workout
      bool success = await _workoutService.deleteWorkout(workoutId);

      if (success) {
        // If the workout is deleted successfully, remove it from the provider's list
        removeWorkout(workoutId);
      } else {
        print('Failed to delete workout.');
      }
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }
}
