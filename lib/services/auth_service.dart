import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  Future<void> signIn(String username, String password) async {
    try {
      SignInResult result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      if (!result.isSignedIn) {
        throw Exception('Sign in failed');
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<bool> checkIfSignedIn() async {
    try {
      AuthSession session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  Future<String> getUsername() async {
    try {
      AuthUser user = await Amplify.Auth.getCurrentUser();
      return user.username;
    } catch (e) {
      throw Exception('Could not fetch username');
    }
  }
}
