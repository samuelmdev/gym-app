import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/scheduled_workout.dart';
import 'providers/completed_workout_provider.dart';
import 'providers/scheduled_workout_provider.dart';
import 'providers/workouts_provider.dart';
// import 'services/workout_service.dart';
import 'workout_player.dart';
import 'models/workout.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Workout? _selectedWorkout;
  List<ScheduledWorkout>? _scheduledWorkouts;
  late String userId;
  late List<Workout>? workouts;
  bool skippedScheduled = false;
  late ScheduledWorkout selectedScheduled;

  @override
  void initState() {
    super.initState();

    // Show the dialog if there are scheduled workouts
    if (!skippedScheduled) {
      Future.microtask(() => _showScheduledWorkoutsDialog(context));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)!.settings.arguments as String;

    final workoutsProvider = Provider.of<WorkoutsProvider>(context);
    workouts = workoutsProvider.workouts;

    // Fetch scheduled workouts for today
    final scheduledWorkoutsProvider =
        Provider.of<ScheduledWorkoutsProvider>(context);
    _scheduledWorkouts =
        scheduledWorkoutsProvider.getScheduledWorkoutsForDate(DateTime.now());

    // If there's only one scheduled workout, automatically select it
    if (_scheduledWorkouts != null && _scheduledWorkouts!.length == 1) {
      _selectedWorkout = workouts!.firstWhere(
        (workout) => workout.id == _scheduledWorkouts!.first.workoutID,
        orElse: () => Workout(
            id: 'default',
            name: 'Default Workout',
            type: 'general',
            userId: userId), // Fallback Workout
      );
    }
  }

  void _showScheduledWorkoutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scheduled Workouts'),
          content: _scheduledWorkouts!.length > 1
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _scheduledWorkouts!.map((scheduledWorkout) {
                    // Find the matching workout from the workout list by workoutID
                    Workout? correspondingWorkout =
                        _findWorkoutById(scheduledWorkout.workoutID);
                    return ListTile(
                      title: Text(correspondingWorkout != null
                          ? correspondingWorkout.name
                          : 'Workout not found'),
                      leading: Radio<Workout>(
                        value: correspondingWorkout!,
                        groupValue: _selectedWorkout,
                        onChanged: (Workout? value) {
                          setState(() {
                            _selectedWorkout = value!;
                            selectedScheduled = scheduledWorkout;
                          });
                          Navigator.pop(
                              context); // Close the dialog after selection
                        },
                      ),
                    );
                  }).toList(),
                )
              : Text(
                  'Workout: ${_findWorkoutById(_scheduledWorkouts!.first.workoutID)?.name ?? 'Workout not found'}'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  skippedScheduled = true;
                });
                Navigator.pop(
                    context); // Skip the dialog and continue with regular selection
              },
              child: const Text('Skip'),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // slightly rounded edges
                ),
              ),
              onPressed: () {
                // Auto-select the single workout if none is selected
                if (_scheduledWorkouts!.length == 1) {
                  _selectedWorkout =
                      _findWorkoutById(_scheduledWorkouts!.first.workoutID)!;
                  selectedScheduled = _scheduledWorkouts!.first;
                }
                Provider.of<CompletedWorkoutProvider>(context, listen: false)
                    .startWorkout(userId, _selectedWorkout!);
                Provider.of<ScheduledWorkoutsProvider>(context, listen: false)
                    .deleteScheduledWorkout(selectedScheduled);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkoutPlayer(workout: _selectedWorkout!),
                  ),
                );
                // Navigator.pop(context);
              },
              child: const Text('START'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to find workout by ID from the workout list
  Workout? _findWorkoutById(String workoutID) {
    final workoutsProvider =
        Provider.of<WorkoutsProvider>(context, listen: false);
    List<Workout>? workouts = workoutsProvider.workouts;

    // Find the workout with the matching ID
    return workouts?.firstWhere(
      (workout) => workout.id == workoutID,

      orElse: () => Workout(
          id: 'default',
          name: 'Default Workout',
          type: 'general',
          userId: userId), // Return null if not found
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: workouts == null || workouts!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.yellow,
                    side: const BorderSide(color: Colors.yellow, width: 2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Workout newWorkout =
                        Workout(id: '', name: '', type: '', userId: userId);
                    Provider.of<CompletedWorkoutProvider>(context,
                            listen: false)
                        .startWorkout(userId, newWorkout);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutPlayer(workout: newWorkout),
                      ),
                    );
                  },
                  child: const Text('Start new empty workout'),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Or',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Select Workout',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: workouts?.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedWorkout = workouts![index];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                _selectedWorkout == workouts![index]
                                    ? Colors.yellow
                                    : Colors.white,
                            backgroundColor: Colors.black,
                            side: BorderSide(
                              color: _selectedWorkout == workouts![index]
                                  ? Colors.yellow
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(workouts![index].name),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _selectedWorkout == null
                        ? null
                        : () {
                            Provider.of<CompletedWorkoutProvider>(context,
                                    listen: false)
                                .startWorkout(userId, _selectedWorkout!);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutPlayer(workout: _selectedWorkout!),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text('START'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
