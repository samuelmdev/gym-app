import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/completed_workout_provider.dart';
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
  // List<Workout> _workouts = [];
  // bool _isLoading = false;
  Workout? _selectedWorkout;
  late String userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)!.settings.arguments as String;
    // _fetchWorkouts(userId);
  }
/*
  void _fetchWorkouts(String userId) async {
    try {
      List<Workout> workouts = await WorkoutService.listWorkouts(userId);
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workouts: $e');
    }
  } */

  @override
  Widget build(BuildContext context) {
    List<Workout>? workouts = [];
    Workout newWorkout = Workout(id: '', name: '', type: '', userId: userId);
    final workoutsProvider = Provider.of<WorkoutsProvider>(context);
    workouts = workoutsProvider.workouts;
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: workouts!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Column(children: [
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.yellow,
                      side: const BorderSide(color: Colors.yellow, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // slightly rounded edges
                      ),
                    ),
                    onPressed: () {
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
                    child: const Text('Start new empty'),
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
                ]),
                Expanded(
                  child: ListView.builder(
                    itemCount: workouts.length,
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
                                color: _selectedWorkout == workouts[index]
                                    ? Colors.yellow
                                    : Colors.transparent,
                                width: 2.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // slightly rounded edges
                            ),
                          ),
                          child: Text(workouts[index].name),
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
                                .startWorkout(userId, _selectedWorkout);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutPlayer(workout: _selectedWorkout!),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // slightly rounded edges
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


/*
Stack(
              children: [
                GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _isDragging = true;
                      _dragPosition = details.localPosition.dx;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = details.localPosition.dx;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition > MediaQuery.of(context).size.width * 0.6) {
                      _startWorkout(context, workout);
                    }
                    setState(() {
                      _isDragging = false;
                      _dragPosition = 0.0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        '${workouts!.name}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.yellow),
                        onPressed: () => {
                            Provider.of<CompletedWorkoutProvider>(context,
                                    listen: false)
                                .startWorkout(userId, _selectedWorkout),
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutPlayer(workout: _selectedWorkout!),
                              ),
                            )},
                      ),
                    ),
                  ),
                ),
                if (_isDragging)
                  Positioned(
                    left: _dragPosition - 50,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Slide to Start',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
              ],
                        ),
                      );
                    },  */