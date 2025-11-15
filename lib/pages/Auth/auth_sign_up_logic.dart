import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthSignUpLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // ✅ Firestore instance
  bool _isLoading = false;

  /// Sign up with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (_isLoading) return false; // prevent multiple taps

    // ✅ Validate empty fields
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      _showErrorSnackBar(context, 'All fields are required.');
      return false;
    }

    // ✅ Cross-platform connectivity check
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorSnackBar(context, 'No internet connection.');
      return false;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // ✅ Store user info in Firestore under their UID
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
        'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> _closeLoadingAndNavigate(BuildContext context) async {
    _isLoading = false;

    if (context.mounted) {
      // ✅ Pop the loading dialog first
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homescreen',
          (route) => false,
        );

        // ✅ Show success message after navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
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
      Navigator.of(context, rootNavigator: true).pop(); // pop loading
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
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Failed to create account. Please try again.';
    }
  }
}
