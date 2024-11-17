import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class InitialCheckScreen extends StatefulWidget {
  const InitialCheckScreen({super.key});

  @override
  State<InitialCheckScreen> createState() => _InitialCheckScreenState();
}

class _InitialCheckScreenState extends State<InitialCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      final isSignedIn = session.isSignedIn;

      // Navigate based on auth state
      if (isSignedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/signIn');
      }
    } catch (e) {
      print('Error checking auth status: $e');
      Navigator.of(context).pushReplacementNamed('/signIn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
