import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:gym_app/components/dynamic_tiles.dart';
import 'package:gym_app/models/date.dart';
import 'package:gym_app/providers/ready_workout_provider.dart';
import 'package:provider/provider.dart';

import 'providers/exercises_provider.dart';
import 'providers/scheduled_workout_provider.dart';
import 'providers/workouts_provider.dart';
import 'services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  Future<void> _getUsername() async {
    String username = await AuthService().getUsername();
    setState(() {
      _username = username;
    });
  }

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
                            .fetchWorkouts(userId),
                        Provider.of<ScheduledWorkoutsProvider>(context,
                                listen: false)
                            .fetchScheduledWorkouts(userId),
                        Provider.of<ReadyWorkoutProvider>(context,
                                listen: false)
                            .fetchReadyWorkouts(userId),
                      });
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Welcome, $_username 🔥',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 40),
                        const DynamicTiles(),
                        const SizedBox(height: 40),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/planner', arguments: userId),
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
