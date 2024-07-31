import 'package:flutter/material.dart';
import 'package:gym_app/models/exercise.dart';

import '../services/exercises_service.dart';

class ExercisesProvider with ChangeNotifier {
  List<Exercise>? _exercises;
  bool _isLoading = false;

  List<Exercise>? get exercises => _exercises;
  bool get isLoading => _isLoading;

  Future<void> fetchExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await ExerciseService.fetchExercises();
    } catch (error) {
      // Handle errors if needed
      print("Error fetching exercises: $error");
    }

    _isLoading = false;
    notifyListeners();
  }
}
