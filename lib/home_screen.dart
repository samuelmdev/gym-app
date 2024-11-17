import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:gym_app/components/dynamic_tiles.dart';
import 'package:gym_app/models/date.dart';
import 'package:gym_app/providers/ready_workout_provider.dart';
import 'package:provider/provider.dart';

import 'models/ready_workout.dart';
import 'models/scheduled_workout.dart';
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
  Map<DateTime, List<ReadyWorkout>> _groupedWorkouts = {};
  final int _selectedWeek = 0;
  late String userId = '';
  Map<String, int> stats = {};
  late List<ScheduledWorkout>? todayScheduledWorkouts = [];
  bool _isLoadingUsername = true;
  bool _isLoadingUserId = true;
  bool _isLoadingWorkouts = true;
  bool _isLoadingStats = true;
  late WorkoutsProvider workoutsProvider;
  late ReadyWorkoutProvider readyWorkoutProvider;
  late ScheduledWorkoutsProvider scheduledWorkoutsProvider;
  late ExercisesProvider exercisesProvider;

  @override
  void initState() {
    super.initState();
    workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: false);
    readyWorkoutProvider =
        Provider.of<ReadyWorkoutProvider>(context, listen: false);
    scheduledWorkoutsProvider =
        Provider.of<ScheduledWorkoutsProvider>(context, listen: false);
    exercisesProvider = Provider.of<ExercisesProvider>(context, listen: false);
    _getUsername();
    _waitUserIdAndLoadWorkouts();
    _loadUserData();
    _loadWorkouts();
  }

  Future<void> _waitUserIdAndLoadWorkouts() async {
    try {
      // Simulate fetching userId asynchronously, replace with actual database logic

      // ignore: unnecessary_null_comparison
      while (userId == '') {
        await Future.delayed(
            const Duration(milliseconds: 100)); // Check every 100ms
      }

      if (userId != '') {
        // Once the userId is fetched, load the workouts
        _loadWorkouts();
        await _checkTodayScheduledWorkout();
      }
    } catch (e) {
      print('Error fetching userId: $e');
      // Handle the error
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Get username
      await _getUsername();

      // Get user email and ID
      final email = await getUserEmail();
      final fetchedUserId = await fetchUserIdByUsername(email);

      setState(() {
        userId = fetchedUserId;
        _isLoadingUserId = false;
      });

      // Fetch workout data once the user ID is available
      await _fetchWorkoutsData(fetchedUserId);
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUserId = false;
        _isLoadingWorkouts = false;
      });
    }
  }

  void _loadWorkouts() async {
    readyWorkoutProvider.fetchReadyWorkouts(userId);
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _selectedWeek * 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    while (readyWorkoutProvider.readyWorkouts.isEmpty) {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Check every 100ms
    }

    // Fetch workouts within the selected week, grouped by date
    Map<DateTime, List<ReadyWorkout>> groupedWorkouts =
        readyWorkoutProvider.getReadyWorkoutsByDay(startOfWeek, endOfWeek);

    // Normalize the dates (set time to midnight)
    groupedWorkouts = groupedWorkouts.map((date, workouts) {
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      return MapEntry(normalizedDate, workouts);
    });

    setState(() {
      _groupedWorkouts = groupedWorkouts;

      // Calculate statistics
      _calculateWorkoutStats(groupedWorkouts);
    });
    print('home _goupedWorkouts: $groupedWorkouts');
  }

  Future<void> _fetchWorkoutsData(String userId) async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _selectedWeek * 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    await Future.wait([
      exercisesProvider.fetchExercises(),
      workoutsProvider.fetchWorkouts(userId),
      scheduledWorkoutsProvider.fetchScheduledWorkouts(userId),
      readyWorkoutProvider.fetchReadyWorkouts(userId),
      scheduledWorkoutsProvider.deletePastScheduledWorkouts(),
    ]);

    setState(() {
      _groupedWorkouts =
          readyWorkoutProvider.getReadyWorkoutsByDay(startOfWeek, endOfWeek);
      _isLoadingWorkouts = false;
    });
  }

  Future<void> _checkTodayScheduledWorkout() async {
    final scheduledWorkoutProvider =
        Provider.of<ScheduledWorkoutsProvider>(context, listen: false);
    DateTime today = DateTime.now();

    List<ScheduledWorkout> todayWorkouts =
        scheduledWorkoutProvider.getScheduledWorkoutsForDate(today);

    if (todayWorkouts.isNotEmpty) {
      setState(() {
        todayScheduledWorkouts =
            todayWorkouts; // Get the first one for simplicity
      });
    } else {
      setState(() {
        todayScheduledWorkouts = null;
      });
    }
  }

// Function to calculate stats based on grouped workouts
  void _calculateWorkoutStats(Map<DateTime, List<ReadyWorkout>> workouts) {
    int totalDuration = 0;
    int totalWeightLifted = 0;
    int totalSetsDone = 0;
    int totalReps = 0;
    int totalBodyweightReps = 0;

    workouts.forEach((date, dailyWorkouts) {
      for (var workout in dailyWorkouts) {
        totalDuration += workout.duration!.inMinutes;
        totalWeightLifted += workout.weightLifted;
        totalSetsDone += workout.doneSets;
        totalReps += workout.totalReps;
        totalBodyweightReps += workout.bodyweightReps;
      }
    });

    setState(() {
      stats = {
        'duration': totalDuration,
        'weightLifted': totalWeightLifted,
        'setsDone': totalSetsDone,
        'totalReps': totalReps,
        'bodyweightReps': totalBodyweightReps,
      };
      _isLoadingStats = false;
    });
  }

  Future<void> _getUsername() async {
    String username = await AuthService().getUsername();
    setState(() {
      _username = username;
      _isLoadingUsername = false;
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
    String formattedDate = CustomDateUtils.formatDate(DateTime.now());
    bool hasScheduledWorkout = todayScheduledWorkouts != null;

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
      body: /* FutureBuilder<String>(
        future: getUserEmail(),
        builder: (context, snapshot) {
          //  if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Center(child: CircularProgressIndicator());
          //    } else if (snapshot.hasError) {
          //     return Center(child: Text('Error: ${snapshot.error}'));
          //   } else {
          final email = snapshot.data!;
          return FutureBuilder<String>(
            future: fetchUserIdByUsername(email),
            builder: (context, idSnapshot) {
              //   if (idSnapshot.connectionState == ConnectionState.waiting) {
              //     return const Center(child: CircularProgressIndicator());
              //  } else if (idSnapshot.hasError) {
              //    return Center(child: Text('Error: ${idSnapshot.error}'));
              //   } else {
              userId = idSnapshot.data!;
              _isLoadingUserId = false;

              Future.microtask(() => {
                    Provider.of<ExercisesProvider>(context, listen: false)
                        .fetchExercises(),
                    Provider.of<WorkoutsProvider>(context, listen: false)
                        .fetchWorkouts(userId),
                    Provider.of<ScheduledWorkoutsProvider>(context,
                            listen: false)
                        .fetchScheduledWorkouts(userId),
                    Provider.of<ReadyWorkoutProvider>(context, listen: false)
                        .fetchReadyWorkouts(userId),
                    // Call the method to delete past scheduled workouts
                    Provider.of<ScheduledWorkoutsProvider>(context,
                            listen: false)
                        .deletePastScheduledWorkouts(),
                  });
              _isLoadingWorkouts = false;
              return */
          Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16),
            ),
            _isLoadingUsername
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    'Welcome, $_username 🔥',
                    style: const TextStyle(fontSize: 20),
                  ),
            const SizedBox(height: 40),
            /*   _isLoadingUserId || _isLoadingWorkouts
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : */
            DynamicTiles(
                groupedWorkouts: _groupedWorkouts,
                stats: stats,
                userId: userId,
                loadingComplete: readyWorkoutProvider.handlingDailyData,
                isLoadingStats: _isLoadingStats),
            const SizedBox(height: 40),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoadingWorkouts
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            '/planner',
                            arguments: userId,
                          ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.yellow,
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.yellow, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // slightly rounded edges
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
                  onPressed: _isLoadingWorkouts
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed('/workoutsList', arguments: userId),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.yellow,
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.yellow, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // slightly rounded edges
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
                  onPressed: _isLoadingWorkouts || userId.length < 3
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            '/workouts',
                            arguments: userId,
                          ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        hasScheduledWorkout ? Colors.white : Colors.black,
                    backgroundColor:
                        hasScheduledWorkout ? Colors.lightBlue : Colors.yellow,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('START WORKOUT'),
                ),
              ],
            ),
          ],
        ),
      ),
      //  }
      //     },
    );
    //    }
    //    },
    //   ),
    //   );
  }
}
