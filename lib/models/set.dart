// lib/models/Set.dart

class Set {
  final String id;
  final List<int> reps;
  final List<int>? weight;
  final String exercisesId;
  final String? workoutID;

  Set({
    required this.id,
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
}
