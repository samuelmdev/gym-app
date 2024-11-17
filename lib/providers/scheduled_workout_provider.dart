import '../services/schedule_workout_service.dart';
import '../models/scheduled_workout.dart';
import 'base_provider.dart';

class ScheduledWorkoutsProvider extends BaseProvider {
  List<ScheduledWorkout> _scheduledWorkouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ScheduledWorkout> get scheduledWorkouts => _scheduledWorkouts;
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;

  Future<void> fetchScheduledWorkouts(String userID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    setMainLoading(true);
    setErrorMessage(null);

    try {
      _scheduledWorkouts =
          await ScheduledWorkoutService.fetchScheduledWorkoutsByUserID(userID);
    } catch (e) {
      _errorMessage = 'Failed to fetch scheduled workouts';
      setErrorMessage('Failed to fetch scheduled workouts');
    } finally {
      _isLoading = false;
      setMainLoading(false);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get scheduled workouts for a given date
  List<ScheduledWorkout> getScheduledWorkoutsForDate(DateTime date) {
    String formattedDate = formatDateToAWSDate(date);

    return _scheduledWorkouts.where((workout) {
      // Compare formattedDate with workout.date
      return workout.date == formattedDate;
    }).toList();
  }

  Map<DateTime, List<ScheduledWorkout>> getScheduledWorkoutsByDay(
      DateTime start, DateTime end) {
    Map<DateTime, List<ScheduledWorkout>> groupedScheduledWorkouts = {};

    // Iterate through each day from start to end (inclusive)
    DateTime currentDate = start;
    while (!currentDate.isAfter(end)) {
      // Get scheduled workouts for the current date
      List<ScheduledWorkout> workoutsForDate =
          getScheduledWorkoutsForDate(currentDate);

      // If there are scheduled workouts for the current date, add them to the map
      if (workoutsForDate.isNotEmpty) {
        groupedScheduledWorkouts[currentDate] = workoutsForDate;
      }

      // Move to the next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return groupedScheduledWorkouts;
  }

  // Helper method to format DateTime to AWSDate format (YYYY-MM-DD)
  String formatDateToAWSDate(DateTime date) {
    return '${date.toUtc().year.toString().padLeft(4, '0')}-${date.toUtc().month.toString().padLeft(2, '0')}-${date.toUtc().day.toString().padLeft(2, '0')}';
  }

  // Delete scheduled workout
  Future<void> deleteScheduledWorkout(ScheduledWorkout workout) async {
    // Remove from the local list
    _scheduledWorkouts.removeWhere((w) => w.id == workout.id);
    print("delete scheduled caaled in provider");

    // Notify listeners
    notifyListeners();

    // Call the service to delete the workout from the database
    await ScheduledWorkoutService.deleteScheduledWorkout(workout.id);
  }

  // Delete all scheduled workouts before today's date
  Future<void> deletePastScheduledWorkouts() async {
    DateTime today = DateTime.now();
    DateTime normalizedToday =
        DateTime(today.year, today.month, today.day); // Normalize today

    // Filter out the workouts before today
    List<ScheduledWorkout> pastWorkouts = _scheduledWorkouts.where((workout) {
      return _normalizeDateString(workout.date).isBefore(normalizedToday);
    }).toList();

    try {
      // Delete each scheduled workout that is before today
      for (var workout in pastWorkouts) {
        await ScheduledWorkoutService.deleteScheduledWorkout(
          workout.id,
        );
      }

      // Remove past workouts from the local list
      _scheduledWorkouts.removeWhere((workout) =>
          _normalizeDateString(workout.date).isBefore(normalizedToday));

      notifyListeners(); // Notify the UI about the state change
    } catch (error) {
      print('Error deleting past scheduled workouts: $error');
      rethrow;
    }
  }

  // Helper method to convert the String date to DateTime
  DateTime _parseDateString(String dateString) {
    try {
      return DateTime.parse(
          dateString); // Assuming the date is in 'YYYY-MM-DD' format
    } catch (e) {
      throw Exception('Invalid date format: $dateString');
    }
  }

  // Helper method to convert and normalize the String date to DateTime
  DateTime _normalizeDateString(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString); // Assuming 'YYYY-MM-DD'
      return DateTime(parsedDate.year, parsedDate.month,
          parsedDate.day); // Normalizing to midnight
    } catch (e) {
      throw Exception('Invalid date format: $dateString');
    }
  }

/*
  // Method to delete a single scheduled workout
  Future<void> deleteScheduledWorkout(String workoutId) async {
    try {
      // Call service to delete the workout from Firestore or database
      await ScheduledWorkoutService.deleteScheduledWorkout(workoutId);

      // Remove workout from local list
      _scheduledWorkouts
          .removeWhere((workout) => workout.workoutID == workoutId);
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      print('Error deleting scheduled workout: $e');
    }
  }

  // Method to delete all past workouts (yesterday and earlier)
  Future<void> deletePastScheduledWorkouts() async {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    try {
      List<ScheduledWorkout> pastWorkouts = _scheduledWorkouts.where((workout) {
        return workout.date.isBefore(today);
      }).toList();

      for (var workout in pastWorkouts) {
        await ScheduledWorkoutService.deleteScheduledWorkout(workout.workoutID);
      }

      // Remove past workouts from the local list
      _scheduledWorkouts
          .removeWhere((workout) => workout.date.isBefore(yesterday));
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      print('Error deleting past scheduled workouts: $e');
    }
  } */
}
