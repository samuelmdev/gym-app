import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:gym_app/models/date.dart';
import 'package:provider/provider.dart';

import 'providers/exercises_provider.dart';
import 'providers/workouts_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.username});
  final String username;

  Future<String> fetchUserIdByUsername(String email) async {
    String getUserByEmailQuery = '''
      query GetUserByUsername(\$username: String!) {
        listUsers(filter: {username: {eq: \$username}}) {
          items {
            id
            username
          }
        }
      }
    ''';

    try {
      var request = GraphQLRequest<String>(
        document: getUserByEmailQuery,
        variables: {'username': email},
      );

      print('GraphQL request: ${request.variables}');

      var response = await Amplify.API.query(request: request).response;
      print('GraphQL response: ${response.data}');

      if (response.errors.isNotEmpty) {
        print('GraphQL errors: ${response.errors}');
        throw Exception('GraphQL errors occurred');
      }

      var data = jsonDecode(response.data!);
      print('Parsed data: $data');

      if (data['listUsers']['items'].isNotEmpty) {
        var userId = data['listUsers']['items'][0]['id'];
        return userId;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user ID: $e');
      return '';
    }
  }

  Future<String> getUserEmail() async {
    try {
      List<AuthUserAttribute> userAttributes =
          await Amplify.Auth.fetchUserAttributes();

      // Print all user attributes
      print('User Attributes:');
      for (var attr in userAttributes) {
        print('${attr.userAttributeKey}: ${attr.value}');
      }

      AuthUserAttribute emailAttribute = userAttributes.firstWhere(
        (attr) => attr.userAttributeKey == AuthUserAttributeKey.email,
      );

      return emailAttribute.value;
    } catch (e) {
      print('Error fetching user email: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    late String userId;

    String formattedDate = CustomDateUtils.formatDate(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'The Gym App',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.yellow),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: getUserEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final email = snapshot.data!;
            return FutureBuilder<String>(
              future: fetchUserIdByUsername(email),
              builder: (context, idSnapshot) {
                if (idSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (idSnapshot.hasError) {
                  return Center(child: Text('Error: ${idSnapshot.error}'));
                } else {
                  userId = idSnapshot.data!;

                  Future.microtask(() => {
                        Provider.of<ExercisesProvider>(context, listen: false)
                            .fetchExercises(),
                        Provider.of<WorkoutsProvider>(context, listen: false)
                            .fetchWorkouts(userId)
                      });
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$formattedDate,',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Welcome, $username! 🔥',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Schedule',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/schedule'),
                            child: const Center(
                              child: Text(
                                'Schedule',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/planner'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.yellow,
                                backgroundColor: Colors.black,
                                side: const BorderSide(
                                    color: Colors.yellow, width: 2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // slightly rounded edges
                                ),
                              ),
                              icon: const Icon(
                                Icons.edit_document,
                                color: Colors.yellow,
                              ),
                              label: const Text('PLANNER'),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/progress'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.yellow,
                                backgroundColor: Colors.black,
                                side: const BorderSide(
                                    color: Colors.yellow, width: 2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // slightly rounded edges
                                ),
                              ),
                              icon: const Icon(
                                Icons.show_chart,
                                color: Colors.yellow,
                              ),
                              label: const Text('Progress'),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/workoutsList'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.yellow,
                                backgroundColor: Colors.black,
                                side: const BorderSide(
                                    color: Colors.yellow, width: 2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // slightly rounded edges
                                ),
                              ),
                              icon: const Icon(
                                Icons.list,
                                color: Colors.yellow,
                              ),
                              label: const Text('My Workouts'),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/workouts', arguments: userId),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.yellow,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // slightly rounded edges
                                ),
                              ),
                              child: const Text('START WORKOUT'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
