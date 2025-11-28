import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogleSignInLogic {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
          message: 'Missing Google ID token',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if the user is new
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Store user info in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name':
              userCredential.user!.displayName ??
              googleUser.displayName ??
              'User',
          'email': userCredential.user!.email ?? googleUser.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ ADD THIS NAVIGATION - This was missing!
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homescreen',
          (route) => false,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signed in with Google')));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase Auth Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign‑In Error: $e')));
      }
    }
  }
}
