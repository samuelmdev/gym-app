import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';

class ReadyWorkoutService {
  // Mutation for creating a ReadyWorkout
  static Future<String> createReadyWorkout({
    // required String id,
    required int weightLifted,
    required int bodyWeightReps,
    required TemporalTimestamp startTimestamp,
    required TemporalTimestamp endTimestamp,
    required int duration,
    required String userID,
    required int doneSets,
    required int totalReps,
  }) async {
    String createReadyWorkoutMutation = '''
      mutation CreateReadyWorkout(\$input: CreateReadyWorkoutInput!) {
        createReadyWorkout(input: \$input) {
          weightLifted
          bodyWeightReps
          startTimestamp
          endTimestamp
          duration
          userID
          doneSets
          totalReps
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: createReadyWorkoutMutation,
      variables: {
        'input': {
          'weightLifted': weightLifted,
          'bodyWeightReps': bodyWeightReps,
          'startTimestamp': startTimestamp,
          'endTimestamp': endTimestamp,
          'duration': duration,
          'userID': userID,
          'doneSets': doneSets,
          'totalReps': totalReps,
        },
      },
    );

    var response = await Amplify.API.mutate(request: request).response;

    if (response.errors.isNotEmpty) {
      throw Exception('Failed to create ready workout: ${response.errors}');
    }

    var data = jsonDecode(response.data!);
    return data['createReadyWorkout']['id'];
  }

  // Mutation for creating a CompletedWorkout
  static Future<void> createCompletedWorkout({
    required String name,
    required String type,
    required String userID,
    required String completedWorkoutReadyWorkoutId,
  }) async {
    String createCompletedWorkoutMutation = '''
      mutation CreateCompletedWorkout(\$input: CreateCompletedWorkoutInput!) {
        createCompletedWorkout(input: \$input) {
          name
          type
          userID
          completedWorkoutReadyWorkoutId
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: createCompletedWorkoutMutation,
      variables: {
        'input': {
          'name': name,
          'type': type,
          'userID': userID,
          'completedWorkoutReadyWorkoutId': completedWorkoutReadyWorkoutId,
        },
      },
    );

    var response = await Amplify.API.mutate(request: request).response;

    if (response.errors.isNotEmpty) {
      throw Exception('Failed to create completed workout: ${response.errors}');
    }
  }
}
