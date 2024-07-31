import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workouts_provider.dart';
import '../providers/exercises_provider.dart';
import '../models/workout.dart';
import 'models/exercise.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({super.key});

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  List<Workout> workouts = [];
  List<Exercise> exercises = [];
  List<Set> sets = [];

  @override
  void initState() {
    super.initState();
    // Fetch workouts and exercises on init
    final workoutProvider =
        Provider.of<WorkoutsProvider>(context, listen: false);
    final exercisesProvider =
        Provider.of<ExercisesProvider>(context, listen: false);
    workouts = workoutProvider.workouts!; // Fetch workouts
    exercises = exercisesProvider.exercises!; // Fetch exercises
  }

  @override
  Widget build(BuildContext context) {
    int selectedWorkout = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        automaticallyImplyLeading: false,
      ),
      body: workouts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'My Workouts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedWorkout == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedWorkout = (isSelected ? null : index)!;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedWorkout == workouts[index]
                              ? Colors.yellow
                              : Colors.white,
                          backgroundColor: Colors.black,
                          side: BorderSide(
                              color: selectedWorkout == workouts[index]
                                  ? Colors.yellow
                                  : Colors.transparent,
                              width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // slightly rounded edges
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(workouts[index].name),
                            if (isSelected) ...[
                              ElevatedButton(
                                  onPressed: () => {},
                                  child: const Icon(
                                    Icons.arrow_downward_outlined,
                                    color: Colors.yellow,
                                  ))
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
