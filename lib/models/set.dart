// lib/models/Set.dart

class Set {
  final String? id;
  final List<int> reps;
  final List<int>? weight;
  final String exercisesId;
  final String? workoutID;

  Set({
    this.id,
    required this.reps,
    this.weight,
    required this.exercisesId,
    this.workoutID,
  });

  Set.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        reps = List<int>.from(json['reps'].map((rep) => rep as int)),
        weight = List<int>.from(json['weight'].map((wt) => wt as int)),
        exercisesId = json['exercises'],
        workoutID = json['workoutID'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'reps': reps,
        'weigth': weight,
        'exercises': exercisesId,
        'workoutID': workoutID,
      };

  Set copyWith({
    String? id,
    List<int>? reps,
    List<int>? weight,
    String? exercisesId,
    String? workoutID,
  }) {
    return Set(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      exercisesId: exercisesId ?? this.exercisesId,
      workoutID: workoutID ?? this.workoutID,
    );
  }
}
