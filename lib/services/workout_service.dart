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
      var decodedData = jsonDecode(data!);

      List<Workout> allWorkouts = (decodedData['listWorkouts']['items'] as List)
          .map((item) => Workout.fromJson(item))
          .toList();

      // Filter workouts by userId
      List<Workout> userWorkouts =
          allWorkouts.where((workout) => workout.userId == userId).toList();

      return userWorkouts;
    } catch (e) {
      print('Failed to fetch workouts: $e');
      throw Exception('Failed to fetch workouts: $e');
    }
  }

  static Future<String?> createWorkout({
    required String name,
    required String type,
    required String userId,
  }) async {
    try {
      // Define the GraphQL mutation
      String graphQLDocument = '''
      mutation CreateWorkout(\$input: CreateWorkoutInput!) {
        createWorkout(input: \$input) {
          id
          name
          type
          userWorkoutsId
        }
      }
    ''';

      // Define the variables for the mutation
      var variables = {
        "name": name,
        "type": type,
        "userWorkoutsId": userId,
      };
      print('Creating workout with input: $variables');

      // Execute the mutation
      var request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'input': variables},
      );

      var response = await Amplify.API.mutate(request: request).response;
      print('create workout called: $response');

      // Handle the response
      if (response.data != null) {
        final data = jsonDecode(response.data!) as Map<String, dynamic>;
        return data['createWorkout']['id'] as String?;
      } else {
        print('Failed to create workout: ${response.errors}');
        return null;
      }
    } catch (e) {
      print('Error creating workout: $e');
      return null;
    }
  }

  static Future<bool> deleteWorkout(String workoutId) async {
    try {
      // Define the GraphQL mutation
      String graphQLDocument = '''
      mutation DeleteWorkout(\$id: ID!) {
        deleteWorkout(input: { id: \$id }) {
          id
        }
      }
    ''';

      // Define the variables for the mutation
      var variables = {
        "id": workoutId,
      };

      // Execute the mutation
      var request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: variables,
      );

      var response = await Amplify.API.mutate(request: request).response;

      // Handle the response
      if (response.data != null) {
        print('Workout deleted with ID: $workoutId');
        return true;
      } else {
        print('Failed to delete workout: ${response.errors}');
        return false;
      }
    } catch (e) {
      print('Error deleting workout: $e');
      return false;
    }
  }
}
