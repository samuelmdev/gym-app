// lib/verification_screen.dart

import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  final String username;
  final AuthService authService;

  const VerificationScreen({
    super.key,
    required this.username,
    required this.authService,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  String _errorMessage = '';

  void _verifyCode() async {
    String code = _codeController.text.trim();

    try {
      // Confirm the sign-up with the code entered by the user
      final result =
          await widget.authService.confirmSignUp(widget.username, code);

      if (result.isSignUpComplete) {
        // If sign-up is completed, navigate to the SignIn screen
        Navigator.of(context).pushReplacementNamed('/signIn');
      } else {
        setState(() {
          _errorMessage = 'Verification not complete. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString(); // Show the error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the verification code sent to your email'),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Verify'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
