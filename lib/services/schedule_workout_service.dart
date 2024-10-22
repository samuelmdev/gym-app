import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../models/scheduled_workout.dart';

class ScheduledWorkoutService {
  static String formatDateToAWSDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  // Mutation for creating a ScheduledWorkout
  static Future<void> createScheduledWorkout({
    required DateTime date,
    required String workoutID,
    required String userID,
  }) async {
    String createScheduledWorkoutMutation = '''
      mutation CreateScheduledWorkout(\$input: CreateScheduledWorkoutInput!) {
        createScheduledWorkout(input: \$input) {
          date
          workoutID
          userID
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: createScheduledWorkoutMutation,
      variables: {
        'input': {
          'date': formatDateToAWSDate(date),
          'workoutID': workoutID,
          'userID': userID,
        },
      },
    );

    try {
      var response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isNotEmpty) {
        throw Exception(
            'Failed to create scheduled workout: ${response.errors}');
      }

      // Print raw response for debugging
      print('Raw response data: ${response.data}');
      var data = jsonDecode(response.data!);
      print('Decoded data: $data');

      // Success: You can handle post-creation logic here
    } catch (e) {
      print('Error creating scheduled workout: $e');
      rethrow;
    }
  }

  static Future<List<ScheduledWorkout>> fetchScheduledWorkoutsByUserID(
      String userID) async {
    String listScheduledWorkoutsQuery = '''
      query ListScheduledWorkouts(\$filter: ModelScheduledWorkoutFilterInput) {
        listScheduledWorkouts(filter: \$filter) {
          items {
            id
            date
            workoutID
            userID
          }
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: listScheduledWorkoutsQuery,
      variables: {
        'filter': {
          'userID': {'eq': userID}
        }
      },
    );

    var response = await Amplify.API.query(request: request).response;

    if (response.errors.isNotEmpty) {
      throw Exception('Failed to fetch scheduled workouts: ${response.errors}');
    }

    var data =
        jsonDecode(response.data!)['listScheduledWorkouts']['items'] as List;
    List<ScheduledWorkout> workouts =
        data.map((item) => ScheduledWorkout.fromJson(item)).toList();

    return workouts;
  }

  // Mutation for deleting a ScheduledWorkout
  static Future<void> deleteScheduledWorkout(String id) async {
    String deleteScheduledWorkoutMutation = '''
      mutation DeleteScheduledWorkout(\$input: DeleteScheduledWorkoutInput!) {
        deleteScheduledWorkout(input: \$input) {
          workoutID
        }
      }
    ''';
    print("delete scheduled called in service");

    var request = GraphQLRequest<String>(
      document: deleteScheduledWorkoutMutation,
      variables: {
        'input': {
          'id': id,
        },
      },
    );

    try {
      // Perform the mutation
      var response = await Amplify.API.mutate(request: request).response;

      // Check if there are any errors
      if (response.errors.isNotEmpty) {
        throw Exception(
            'Failed to delete scheduled workout: ${response.errors}');
      }

      // Optionally, print raw response for debugging
      print('Deleted scheduled workout: ${response.data}');
    } catch (e) {
      print('Error deleting scheduled workout: $e');
      rethrow;
    }
  }
}


/*
  date: ModelSubscriptionStringInput
  workoutID: ModelSubscriptionIDInput
  userID: ModelSubscriptionIDInput

  date: AWSDate
  workoutID: ID! @index(name: "byWorkout")
  userID: ID! @index(name: "byUser")




  */