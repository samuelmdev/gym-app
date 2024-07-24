// lib/models/CompletedWorkout.dart

import 'package:amplify_flutter/amplify_flutter.dart';
import 'workout.dart';
import 'exercise.dart';
import 'set.dart';

class CompletedWorkout {
  final String? userId;
  final Workout? workout;
  List<Exercise>? exercises;
  List<Set>? sets;
  bool? workoutEdited;
  TemporalTimestamp? startTimestamp;
  TemporalTimestamp? stopTimestamp;
  Duration? duration;
  int weightLifted;
  int bodyweightReps;
  int doneSets;

  CompletedWorkout({
    this.userId,
    this.workout,
    this.exercises,
    this.sets,
    this.workoutEdited,
    this.startTimestamp,
    this.stopTimestamp,
    this.duration,
    required this.weightLifted,
    required this.bodyweightReps,
    required this.doneSets,
  });

  CompletedWorkout.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        workout = Workout.fromJson(json['workout']),
        exercises = (json['exercises'] as List)
            .map((exercise) => Exercise.fromJson(exercise))
            .toList(),
        sets = (json['sets'] as List).map((set) => Set.fromJson(set)).toList(),
        workoutEdited = json['workoutEdited'],
        startTimestamp = TemporalTimestamp.fromSeconds(json['startTimestamp']),
        stopTimestamp = TemporalTimestamp.fromSeconds(json['stopTimestamp']),
        duration = Duration(seconds: json['duration']),
        weightLifted = json['weightLifted'],
        bodyweightReps = json['bodyweightReps'],
        doneSets = json['doneSets'];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'workout': workout?.toJson(),
        'exercises': exercises?.map((exercise) => exercise.toJson()).toList(),
        'sets': sets?.map((set) => set.toJson()).toList(),
        'workoutEdited': workoutEdited,
        'startTimestamp': startTimestamp?.toSeconds(),
        'stopTimestamp': stopTimestamp?.toSeconds(),
        'duration': duration?.inSeconds,
        'weightLifted': weightLifted,
        'bodyweightReps': bodyweightReps,
        'doneSets': doneSets,
      };

  void addExercise(Exercise exercise) {
    exercises?.add(exercise);
  }

  void addSet(Set set) {
    sets?.add(set);
  }

  Exercise? getExerciseById(String id) {
    return exercises?.firstWhere((exercise) => exercise.id == id);
  }
}
