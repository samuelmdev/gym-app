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

  Future<void> signUp(String username, String email, String password) async {
    try {
      await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(userAttributes: {
          CognitoUserAttributeKey.email: email, // Stores email in Cognito
        }),
      );

      // If sign up succeeds, save user details to database
      //  await _saveUserToDatabase(email);
    } catch (e) {
      print('Sign-up failed with error: $e');
      throw Exception('Sign-up failed: $e');
    }
  }

  Future<void> _saveUserToDatabase(String email) async {
    const createUserMutation = '''
    mutation CreateUser(\$username: String!) {
      createUser(input: { username: \$username }) {
        id
        username
      }
    }
    ''';

    print('Sending user to database, $email');

    try {
      // Execute the mutation with the email parameter
      final request = GraphQLRequest(
        document: createUserMutation,
        variables: {'username': email},
      );
      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      throw Exception('Error saving user to the database');
    }
  }

  Future<SignUpResult> confirmSignUp(
      String username, String confirmationCode) async {
    try {
      // Call AWS Amplify to confirm sign-up
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      return result; // Return the result
    } catch (e) {
      print('Error confirming sign-up: $e');
      throw Exception('Confirmation failed');
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
