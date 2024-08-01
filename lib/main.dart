import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:gym_app/providers/ready_workout_provider.dart';
import 'package:gym_app/providers/scheduled_workout_provider.dart';
import 'package:gym_app/providers/workouts_provider.dart';
import 'package:gym_app/ready_workout_screen.dart';
import 'package:gym_app/schedule_screen.dart';
import 'package:provider/provider.dart';
import 'amplifyconfiguration.dart';
import 'planner_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'providers/completed_workout_provider.dart';
import 'providers/exercises_provider.dart';
import 'providers/sets_provider.dart';
import 'services/auth_service.dart';
import 'workout_screen.dart';
import 'sign_in_screen.dart';
import 'home_screen.dart';
import './workout_player.dart';
import './set_player.dart';
import './models/workout.dart';
import './models/exercise.dart';
import './models/completed_workout.dart';
import 'workoutlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExercisesProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutsProvider()),
        ChangeNotifierProvider(create: (_) => SetsProvider()),
        ChangeNotifierProvider(create: (_) => CompletedWorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ScheduledWorkoutsProvider()),
        ChangeNotifierProvider(create: (_) => ReadyWorkoutProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    Amplify.addPlugin(AmplifyAuthCognito());
    Amplify.addPlugin(AmplifyAPI());

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('An error occurred configuring Amplify: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;
  bool _isSignedIn = false;
  late String userID;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkUserSignInStatus();
    if (Amplify.isConfigured) {
      setState(() {
        _isAmplifyConfigured = true;
      });
    } else {
      Amplify.addPlugin(AmplifyAuthCognito());
      Amplify.addPlugin(AmplifyAPI());

      try {
        await Amplify.configure(amplifyconfig);
        setState(() {
          _isAmplifyConfigured = true;
        });
      } catch (e) {
        print('An error occurred configuring Amplify: $e');
      }
    }
  }

  Future<void> _checkUserSignInStatus() async {
    try {
      await Amplify.Auth.getCurrentUser();
      setState(() {
        _isSignedIn = true;
      });
    } catch (e) {
      setState(() {
        _isSignedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.yellow,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.yellow, // foreground (text) color
          ),
        ),
      ),
      home: _isAmplifyConfigured
          ? (_isSignedIn
              ? HomeScreen()
              : SignInScreen(authService: AuthService()))
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
      routes: {
        '/workouts': (context) => const WorkoutScreen(),
        '/workoutPlayer': (context) => WorkoutPlayer(
            workout: ModalRoute.of(context)!.settings.arguments as Workout),
        '/setPlayer': (context) => SetPlayer(
            completedWorkout:
                ModalRoute.of(context)!.settings.arguments as CompletedWorkout,
            exercise: ModalRoute.of(context)!.settings.arguments as Exercise),
        '/readyWorkout': (context) => ReadyWorkoutScreen(
              completedWorkout: ModalRoute.of(context)!.settings.arguments
                  as CompletedWorkout,
            ), // Replace with your MyWorkouts screen
        '/schedule': (context) => const ScheduleScreen(),
        '/workoutsList': (context) => const WorkoutList(),
        '/planner': (context) => const PlannerScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
