import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final DatabaseService _db;

  AuthRepository() 
    : _auth = FirebaseAuth.instance,
      _db = DatabaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    UserCredential? credential;
    try {
      // Create auth user
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        try {
          // Wait for authentication to be fully initialized
          await Future.delayed(const Duration(seconds: 1));
          
          // Verify the user is still signed in
          if (_auth.currentUser == null) {
            throw 'Authentication failed';
          }

          final user = UserModel(
            id: credential.user!.uid,
            fullName: fullName.trim(),
            email: email.trim(),
            createdAt: DateTime.now(),
          );
          
          await _db.createUserProfile(user);
          return credential;
        } catch (e) {
          debugPrint('Error creating profile: $e');
          // Clean up: delete auth user if profile creation fails
          await credential.user?.delete();
          throw 'Failed to create user profile. Please try again.';
        }
      } else {
        throw 'Failed to create account';
      }
    } on FirebaseAuthException catch (e) {
      // Clean up if needed
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          throw 'Password should be at least 6 characters';
        case 'email-already-in-use':
          throw 'This email is already registered';
        case 'invalid-email':
          throw 'Please enter a valid email address';
        default:
          throw e.message ?? 'An error occurred during sign up';
      }
    } catch (e) {
      // Clean up if needed
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      
      debugPrint('Signup error: $e');
      throw 'Failed to create account. Please try again.';
    }
  }

  // Sign In
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      }
      throw e.message ?? 'An error occurred during sign in.';
    } catch (e) {
      throw 'An error occurred during sign in.';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred while resetting password.';
    }
  }
} 