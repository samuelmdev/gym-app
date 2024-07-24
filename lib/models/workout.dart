class Workout {
  final String id;
  final String name;
  final String type;
  final String userId;

  Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      userId: json['userWorkoutsId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'userWorkoustId': userId,
    };
  }
}
