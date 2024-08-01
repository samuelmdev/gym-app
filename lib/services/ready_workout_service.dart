import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:gym_app/models/ready_workout.dart';

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
          weightlifted
          bodyweightreps
          starttimestamp
          endtimestamp
          duration
          userID
          donesets
          totalreps
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: createReadyWorkoutMutation,
      variables: {
        'input': {
          'weightlifted': weightLifted,
          'bodyweightreps': bodyWeightReps,
          'starttimestamp': startTimestamp.toSeconds(),
          'endtimestamp': endTimestamp.toSeconds(),
          'duration': duration,
          'userID': userID,
          'donesets': doneSets,
          'totalreps': totalReps,
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

  static Future<List<ReadyWorkout>> fetchReadyWorkoutsByUserID(
      String userID) async {
    String listReadyWorkoutsQuery = '''
      query ListReadyWorkouts(\$filter: ModelReadyWorkoutFilterInput) {
        listReadyWorkouts(filter: \$filter) {
          items {
            id
            userID
            starttimestamp
            endtimestamp
            duration
            weightlifted
            bodyweightreps
            donesets
            totalreps
          }
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: listReadyWorkoutsQuery,
      variables: {
        'filter': {
          'userID': {'eq': userID}
        }
      },
    );

    var response = await Amplify.API.query(request: request).response;

    if (response.errors.isNotEmpty) {
      throw Exception('Failed to fetch ready workouts: ${response.errors}');
    }

    var data = jsonDecode(response.data!)['listReadyWorkouts']['items'] as List;
    print('Raw Data: $data'); // Debug statement
    List<ReadyWorkout> workouts =
        data.map((item) => ReadyWorkout.fromJson(item)).toList();

    return workouts;
  }
}
