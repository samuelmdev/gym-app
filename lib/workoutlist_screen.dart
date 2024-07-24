import 'package:flutter/material.dart';

class WorkoutsList extends StatelessWidget {
  const WorkoutsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts List'),
      ),
      body: const Center(
        child: Text('Workouts List Page'),
      ),
    );
  }
}
