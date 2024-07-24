import 'package:flutter/material.dart';
import 'package:gym_app/models/exercise.dart';

class ExercisesProvider with ChangeNotifier {
  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  void setExercises(List<Exercise> exercises) {
    _exercises = exercises;
    notifyListeners();
  }
}
