import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';

/*
Future<String> fetchUserIdByUsername(String email) async {
  String getUserByEmailQuery = '''
    query GetUserByEmail(\$email: String!) {
      listUsers(filter: {email: {eq: \$email}}) {
        items {
          id
          email
        }
      }
    }
  ''';

  try {
    var request = GraphQLRequest<String>(
      document: getUserByEmailQuery,
      variables: {'username': email},
    );

    var response = await Amplify.API.query(request: request).response;
    var data = jsonDecode(response.data!);
    if (data['listUsers']['items'].isNotEmpty) {
      var userId = data['listUsers']['items'][0]['id'];
      return userId;
    } else {
      throw Exception('User not found');
    }
  } catch (e) {
    print('User email: $email');
    print('Error fetching user ID: $e');
    return '';
  }
} */

Future<void> _fetchUserId(String email) async {
  const String getUserByUsernameQuery = '''
query GetUserByUsername(\$username: String!) {
  listUsers(filter: { username: { eq: \$username } }) {
    items {
      id
      username
      // other fields
    }
  }
}
''';
  try {
    var operation = Amplify.API.query(
      request: GraphQLRequest<String>(
        document: getUserByUsernameQuery,
        variables: {'username': email},
      ),
    );

    var response = await operation.response;
    if (response.data != null) {
      var data = response.data;
      var jsonResponse = jsonDecode(data!);
      var items = jsonResponse['listUsers']['items'];
      if (items.isNotEmpty) {
        var userId = items[0]['id'];
        return userId;
      }
    }
  } catch (e) {
    print('Error fetching user ID: $e');
  }
}

Future<String> getUserEmail() async {
  try {
    AuthUser user = await Amplify.Auth.getCurrentUser();
    return user.username; // Assuming the username is the email
  } catch (e) {
    print('Error fetching user email: $e');
    return '';
  }
}