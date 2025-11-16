import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthSignInLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter both email and password.');
      return false;
    }

    // Check connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorSnackBar(context, _getFirebaseErrorMessage('no-connection'));
      return false;
    }

    if (!context.mounted) return false;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (!context.mounted) return false;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/homescreen',
        (route) => false,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, _getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _showErrorSnackBar(
        context,
        'Something went wrong. Please try again later.',
      );
      return false;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support if this is a mistake.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please check your credentials and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';
      case 'no-connection':
        return 'No internet connection detected. Please check your connectivity and try again.';
      default:
        return 'An unexpected error occurred. Please check your credentials or connectivity and try again.';
    }
  }
}
