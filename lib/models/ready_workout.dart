// lib/models/CompletedWorkout.dart

import 'package:amplify_flutter/amplify_flutter.dart';
import 'workout.dart';

class ReadyWorkout {
  final String id;
  final String? userId;
  final Workout? workout;
  bool? workoutEdited;
  TemporalTimestamp? startTimestamp;
  TemporalTimestamp? stopTimestamp;
  Duration? duration;
  int weightLifted;
  int bodyweightReps;
  int doneSets;
  int totalReps;

  ReadyWorkout({
    required this.id,
    this.userId,
    this.workout,
    this.workoutEdited,
    this.startTimestamp,
    this.stopTimestamp,
    this.duration,
    required this.weightLifted,
    required this.bodyweightReps,
    required this.doneSets,
    required this.totalReps,
  });

  ReadyWorkout.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        workout = Workout.fromJson(json['workout']),
        workoutEdited = json['workoutEdited'],
        startTimestamp = TemporalTimestamp.fromSeconds(json['startTimestamp']),
        stopTimestamp = TemporalTimestamp.fromSeconds(json['stopTimestamp']),
        duration = Duration(seconds: json['duration']),
        weightLifted = json['weightLifted'],
        bodyweightReps = json['bodyweightReps'],
        doneSets = json['doneSets'],
        totalReps = json['totalReps'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'workout': workout?.toJson(),
        'workoutEdited': workoutEdited,
        'startTimestamp': startTimestamp?.toSeconds(),
        'stopTimestamp': stopTimestamp?.toSeconds(),
        'duration': duration?.inSeconds,
        'weightLifted': weightLifted,
        'bodyweightReps': bodyweightReps,
        'doneSets': doneSets,
        'totalReps': totalReps,
      };
}
