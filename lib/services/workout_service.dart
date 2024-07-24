// lib/workout_service.dart

import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/workout.dart';

class WorkoutService {
  static Future<List<Workout>> listWorkouts(String userId) async {
    String graphQLDocument = '''
      query ListWorkouts {
        listWorkouts {
          items {
            id
            name
            type
            userWorkoutsId
          }
        }
      }
    ''';

    try {
      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(document: graphQLDocument),
      );
      var response = await operation.response;
      var data = response.data;
      print('User Id: $userId'); // Debug statement
      print('Raw Data: $data'); // Debug statement
      var decodedData = jsonDecode(data!);
      print('Decoded Data: $decodedData'); // Debug statement

      List<Workout> allWorkouts = (decodedData['listWorkouts']['items'] as List)
          .map((item) => Workout.fromJson(item))
          .toList();

      // Filter workouts by userId
      List<Workout> userWorkouts =
          allWorkouts.where((workout) => workout.userId == userId).toList();
      print('User Workouts: $userWorkouts'); // Debug statement
      print('User Id: $userId'); // Debug statement

      return userWorkouts;
    } catch (e) {
      print('Failed to fetch workouts: $e');
      throw Exception('Failed to fetch workouts: $e');
    }
  }

/*  static Future<List<Set>> listSingleSets(String workoutId) async {
    String listSetsQuery = '''
      query ListSingleSets(\$workoutId: ID!) {
        listSingleSets(filter: {workoutSetsId: {eq: \$workoutId}}) {
          items {
            id
            reps
            weight
            singleSetExercisesId
          }
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: listSetsQuery,
      variables: {'workoutId': workoutId},
    );
    print('workoutId: $workoutId'); // Debug statement

    var response = await Amplify.API.query(request: request).response;
    print('Response: $response'); // Debug statement
    var data = jsonDecode(response.data!);
    print('Data: $data'); // Debug statement
    List<Set> sets = (data['listSets']['items'] as List)
        .map((item) => Set(
            id: item['id'],
            reps: item['reps'],
            weight: item['weight'],
            singleSetExercisesId: item['singleSetExercisesId']))
        .toList();

    return sets;
  } */
}
