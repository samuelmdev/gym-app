// lib/models/CompletedWorkout.dart

import 'package:amplify_flutter/amplify_flutter.dart';

class ReadyWorkout {
  final String id;
  final String? userId;
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
        userId = json['userID'],
        startTimestamp = TemporalTimestamp.fromSeconds(json['starttimestamp']),
        stopTimestamp = TemporalTimestamp.fromSeconds(json['endtimestamp']),
        duration = Duration(seconds: json['duration']),
        weightLifted = json['weightlifted'],
        bodyweightReps = json['bodyweightreps'],
        doneSets = json['donesets'],
        totalReps = json['totalreps'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userId,
        'starttimestamp': startTimestamp?.toSeconds(),
        'endtimestamp': stopTimestamp?.toSeconds(),
        'duration': duration?.inSeconds,
        'weightlifted': weightLifted,
        'bodyweightreps': bodyweightReps,
        'donesets': doneSets,
        'totalreps': totalReps,
      };
}
