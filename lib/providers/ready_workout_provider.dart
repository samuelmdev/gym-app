import 'package:flutter/material.dart';
import 'package:gym_app/models/ready_workout.dart';
import 'package:gym_app/utils/timestamp_extension.dart';

import '../services/ready_workout_service.dart';

class ReadyWorkoutProvider extends ChangeNotifier {
  List<ReadyWorkout> _readyWorkouts = [];
  bool _isLoading = true;
  bool _handlingDailyData = true;
  String? _errorMessage;

  List<ReadyWorkout> get readyWorkouts => _readyWorkouts;
  bool get isLoading => _isLoading;
  bool get handlingDailyData => _handlingDailyData;
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

  List<ReadyWorkout> getReadyWorkoutsByDate(DateTime date) {
    Future.microtask(() {
      _handlingDailyData = true;
      notifyListeners();
    });

    final filteredWorkouts = _readyWorkouts.where((workout) {
      DateTime startTimestamp = workout.startTimestamp!.toDateTime();
      print(startTimestamp);
      return startTimestamp.year == date.year &&
          startTimestamp.month == date.month &&
          startTimestamp.day == date.day;
    }).toList();

    Future.microtask(() {
      _handlingDailyData = false;
      notifyListeners();
    });

    return filteredWorkouts;
  }

  List<ReadyWorkout> getReadyWorkoutsByTimeFrame(DateTime start, DateTime end) {
    return _readyWorkouts.where((workout) {
      DateTime startTimestamp = workout.startTimestamp!.toDateTime();
      return startTimestamp.isAfter(start) && startTimestamp.isBefore(end);
    }).toList();
  }

// Group workouts by date for a given time frame
  Map<DateTime, List<ReadyWorkout>> getReadyWorkoutsByDay(
      DateTime start, DateTime end) {
    Map<DateTime, List<ReadyWorkout>> groupedWorkouts = {};

    // Iterate through each day from start to end (inclusive)
    DateTime currentDate = start;
    while (!currentDate.isAfter(end)) {
      // Get workouts for the current date
      List<ReadyWorkout> workoutsForDate = getReadyWorkoutsByDate(currentDate);

      // If there are workouts for the current date, add them to the map
      if (workoutsForDate.isNotEmpty) {
        groupedWorkouts[currentDate] = workoutsForDate;
      }

      // Move to the next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return groupedWorkouts;
  }
}
