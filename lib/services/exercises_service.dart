// lib/services/exercise_service.dart

import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../models/exercise.dart';

class ExerciseService {
  static Future<List<Exercise>> fetchExercises() async {
    String listExercisesQuery = '''
      query ListExercises {
        listExercises {
          items {
            id
            name
            target
            type
          }
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: listExercisesQuery,
    );

    var response = await Amplify.API.query(request: request).response;
    var data = jsonDecode(response.data!);
    List<Exercise> exercises = (data['listExercises']['items'] as List)
        .map((item) => Exercise.fromJson(item))
        .toList();

    return exercises;
  }
}
