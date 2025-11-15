import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends a password reset email to the user
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    if (email.isEmpty) {
      _showSnackBar(context, 'Please enter your email');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _showSnackBar(context, 'Password reset email sent. Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(context, e.message ?? 'An error occurred');
    } catch (e) {
      _showSnackBar(context, 'Something went wrong. Try again.');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
