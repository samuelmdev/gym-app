import 'package:flutter/material.dart';
import '../services/schedule_workout_service.dart';
import '../models/scheduled_workout.dart';

class ScheduledWorkoutsProvider extends ChangeNotifier {
  List<ScheduledWorkout> _scheduledWorkouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ScheduledWorkout> get scheduledWorkouts => _scheduledWorkouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchScheduledWorkouts(String userID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scheduledWorkouts =
          await ScheduledWorkoutService.fetchScheduledWorkoutsByUserID(userID);
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