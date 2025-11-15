import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthSignInLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (_isLoading) return false;

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showErrorSnackBar(context, 'Email and password cannot be empty.');
      return false;
    }

    // ✅ Check Internet connectivity before trying to sign in
    // ✅ Cross-platform connectivity check
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorSnackBar(context, 'No internet connection.');
      return false;
    }

    if (!context.mounted) return false;

    _isLoading = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _closeLoadingAndNavigate(context);
      return true;
    } on FirebaseAuthException catch (e) {
      await _closeLoadingAndShowError(
        context,
        _getFirebaseErrorMessage(e.code),
      );
      return false;
    } catch (e) {
      await _closeLoadingAndShowError(
        context,
        'Something went wrong: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> _closeLoadingAndNavigate(BuildContext context) async {
    _isLoading = false;

    if (context.mounted) {
      // ✅ UPDATED LINE
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homescreen',
          (route) => false,
        );
      }
    }
  }

  Future<void> _closeLoadingAndShowError(
    BuildContext context,
    String message,
  ) async {
    _isLoading = false;

    if (context.mounted) {
      // ✅ UPDATED LINE
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        _showErrorSnackBar(context, message);
      }
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
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
