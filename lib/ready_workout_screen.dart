import 'package:flutter/material.dart';
import 'package:gym_app/components/grey_container.dart';
import 'package:gym_app/home_screen.dart';
import './models/completed_workout.dart';

class ReadyWorkoutScreen extends StatelessWidget {
  final CompletedWorkout completedWorkout;

  const ReadyWorkoutScreen({super.key, required this.completedWorkout});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool dipPop) async {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Workout Summary',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(children: [
                  Text(
                    'Completed workout: ${completedWorkout.workout?.name}',
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Started at: ${completedWorkout.startTimestamp}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Started at: ${completedWorkout.stopTimestamp}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Duration: ${completedWorkout.duration!.inMinutes} minutes',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CustomContainer(
                            text1: '${completedWorkout.weightLifted} kg',
                            text2: 'Lifted Weight'),
                        const SizedBox(
                          width: 10,
                        ),
                        CustomContainer(
                            text1: '${completedWorkout.doneSets}',
                            text2: 'Sets done'),
                        const SizedBox(
                          width: 10,
                        ),
                      ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CustomContainer(
                          text1: '${completedWorkout.totalReps}',
                          text2: 'Reps in total'),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomContainer(
                          text1: '${completedWorkout.bodyweightReps}',
                          text2: 'Bodyweight Reps'),
                    ],
                  ),
                  // Add more details as needed
                ]),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // slightly rounded edges
                    ),
                  ),
                  onPressed: () => {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HomeScreen(username: 'jaska'),
                            ),
                            (Route<dynamic> route) => false),
                      },
                  child: const Text(
                    'Close summary',
                    style: TextStyle(fontSize: 16),
                  )),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
