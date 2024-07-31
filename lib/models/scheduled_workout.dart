class ScheduledWorkout {
  final String id;
  final String date;
  final String workoutID;
  final String userID;

  ScheduledWorkout({
    required this.id,
    required this.date,
    required this.workoutID,
    required this.userID,
  });

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkout(
      id: json['id'],
      date: json['date'],
      workoutID: json['workoutID'],
      userID: json['userID'],
    );
  }
}
