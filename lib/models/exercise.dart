// lib/models/Exercise.dart

class Exercise {
  final String id;
  final String name;
  final String target;
  final String type;

  Exercise({
    required this.id,
    required this.name,
    required this.target,
    required this.type,
  });

  Exercise.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        target = json['target'],
        type = json['type'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': target,
        'type': type,
      };
}
