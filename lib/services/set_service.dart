// lib/services/set_service.dart

import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../models/set.dart';

class SetService {
  static Future<List<Set>> listSingleSets(String workoutId) async {
    String listSetsQuery = '''
      query ListSingleSets(\$workoutID: ID!) {
        listSingleSets(filter: {workoutID: {eq: \$workoutID}}) {
          items {
            id
            reps
            weight
            exercises
            workoutID
          }
        }
      }
    ''';

    var request = GraphQLRequest<String>(
      document: listSetsQuery,
      variables: {'workoutID': workoutId},
    );

    var response = await Amplify.API.query(request: request).response;
    var data = jsonDecode(response.data!);
    List<Set> sets = (data['listSingleSets']['items'] as List)
        .map((item) => Set.fromJson(item))
        .toList();

    return sets;
  }

  static Future<String?> createSingleSet({
    required List<int> reps,
    List<int>? weight,
    required String exerciseId,
    String? workoutId,
  }) async {
    try {
      // Define the GraphQL mutation
      String graphQLDocument = '''
      mutation CreateSingleSet(\$input: CreateSingleSetInput!) {
        createSingleSet(input: \$input) {
          reps
          weight
          workoutID
          exercises
        }
      }
    ''';

      // Define the variables for the mutation
      var variables = {
        "reps": reps,
        "weight": weight ?? [],
        "workoutID": workoutId,
        "exercises": exerciseId,
      };
      print('set variables: $variables');

      // Execute the mutation
      var request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'input': variables},
      );

      var response = await Amplify.API.mutate(request: request).response;
      print('create single set called: $response');

      // Handle the response
      if (response.data != null) {
        final data = jsonDecode(response.data!) as Map<String, dynamic>;
        return data['createSingleSet']['id'] as String?;
      } else {
        print('Failed to create set: ${response.errors}');
        return null;
      }
    } catch (e) {
      print('Error creating set: $e');
      return null;
    }
  }

  Future<bool> deleteSingleSet(String setId) async {
    try {
      // Define the GraphQL mutation
      String graphQLDocument = '''
      mutation DeleteSingleSet(\$id: ID!) {
        deleteSingleSet(input: { id: \$id }) {
          id
        }
      }
    ''';

      // Define the variables for the mutation
      var variables = {
        "id": setId,
      };

      // Execute the mutation
      var request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: variables,
      );

      var response = await Amplify.API.mutate(request: request).response;

      // Handle the response
      if (response.data != null) {
        print('Set deleted with ID: $setId');
        return true;
      } else {
        print('Failed to delete set: ${response.errors}');
        return false;
      }
    } catch (e) {
      print('Error deleting set: $e');
      return false;
    }
  }
}
