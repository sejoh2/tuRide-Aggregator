import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthSignUpLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // ✅ Validate empty fields
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      _showErrorSnackBar(context, 'All fields are required.');
      return false;
    }

    // ✅ Check connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorSnackBar(context, 'No internet connection.');
      return false;
    }

    if (!context.mounted) return false;

    try {
      // ✅ Create user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // ✅ Store user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Navigate
      if (!context.mounted) return false;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/homescreen',
        (route) => false,
      );

      // ✅ Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, _getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _showErrorSnackBar(context, 'Something went wrong. Please try again.');
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
