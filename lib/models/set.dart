// lib/models/Set.dart

class Set {
  final String id;
  final List<int> reps;
  final List<int>? weight;
  final String singleSetExercisesId;

  Set({
    required this.id,
    required this.reps,
    this.weight,
    required this.singleSetExercisesId,
  });

  Set.fromJson(Map<String, dynamic> json)
      : id = json['workoutSetsId'],
        reps = List<int>.from(json['reps'].map((rep) => rep as int)),
        weight = List<int>.from(json['weight'].map((wt) => wt as int)),
        singleSetExercisesId = json['singleSetExercisesId'];

  Map<String, dynamic> toJson() => {
        'workoutSetsId': id,
        'reps': reps,
        'weigth': weight,
        'singleSetExercisesId': singleSetExercisesId,
      };
}
