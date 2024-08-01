import 'package:flutter/material.dart';
import 'package:gym_app/models/ready_workout.dart';

import '../services/ready_workout_service.dart';

class ReadyWorkoutProvider extends ChangeNotifier {
  List<ReadyWorkout> _readyWorkouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReadyWorkout> get readyWorkouts => _readyWorkouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReadyWorkouts(String userID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _readyWorkouts =
          await ReadyWorkoutService.fetchReadyWorkoutsByUserID(userID);
      print('Fetched ready workouts: $_readyWorkouts');
    } catch (e) {
      _errorMessage = 'Failed to fetch scheduled workouts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}