import 'package:flutter/material.dart';
import 'package:gym_app/models/workout.dart';

class WorkoutsProvider with ChangeNotifier {
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  void setExercises(List<Workout> workouts) {
    _workouts = workouts;
    notifyListeners();
  }
}
