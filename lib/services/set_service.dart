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
    print('workoutId: $workoutId'); // Debug statement

    var response = await Amplify.API.query(request: request).response;
    print('Response: $response'); // Debug statement
    var data = jsonDecode(response.data!);
    print('Data: $data'); // Debug statement
    List<Set> sets = (data['listSingleSets']['items'] as List)
        .map((item) => Set.fromJson(item))
        .toList();

    return sets;
  }
}
