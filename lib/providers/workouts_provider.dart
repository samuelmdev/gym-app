import 'package:flutter/material.dart';
import 'package:gym_app/models/workout.dart';

import '../services/workout_service.dart';

class WorkoutsProvider with ChangeNotifier {
  List<Workout>? _workouts;

  List<Workout>? get workouts => _workouts;

  Future<void> fetchWorkouts(String userId) async {
    try {
      _workouts = await WorkoutService.listWorkouts(userId);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch workouts: $e');
    }
  }
}
