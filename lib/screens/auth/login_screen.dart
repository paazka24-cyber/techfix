import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // TODO: _formKey, _emailController, _passwordController, _isLoading
  // TODO: dispose() for both controllers

  Future<void> _submit() async {
    // TODO: validate the form, set loading, then:
    //   await ref.read(authRepositoryProvider).login(email, password);
    // catch FirebaseAuthException and show _friendlyError(e.code)
    // finally: stop loading (check mounted first)
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Scaffold + Form + email field + password field + Login button
    // Add this under the button to reach Register:
    //   TextButton(
    //     onPressed: () => Navigator.push(context,
    //         MaterialPageRoute(builder: (_) => const RegisterScreen())),
    //     child: const Text("Don't have an account? Register"),
    //   ),
    return const Scaffold();
  }
}
