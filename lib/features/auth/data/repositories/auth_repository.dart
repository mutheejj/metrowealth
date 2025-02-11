import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../categories/data/repositories/category_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final DatabaseService _db;
  final FirebaseFirestore _firestore;

  AuthRepository() 
    : _auth = FirebaseAuth.instance,
      _db = DatabaseService(),
      _firestore = FirebaseFirestore.instance;

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
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw 'Failed to create account';
      }

      // Create user profile
      final user = UserModel(
        id: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        createdAt: DateTime.now(),
      );

      // Create user document first
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      // Initialize default categories
      final categoryRepo = CategoryRepository(userCredential.user!.uid);
      try {
        await categoryRepo.initializeDefaultCategories();
      } catch (e) {
        print('Error initializing categories: $e');
        // Don't rethrow - allow signup to continue even if category init fails
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error in signUp: $e');
      rethrow;
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

  // Delete Account
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Reauthenticate before deleting
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw 'Current password is incorrect';
        case 'requires-recent-login':
          throw 'Please log in again before deleting your account';
        default:
          throw e.message ?? 'An error occurred while deleting account';
      }
    } catch (e) {
      throw 'Failed to delete account';
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Get credentials for reauthentication
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Reauthenticate user
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw 'Current password is incorrect';
        case 'weak-password':
          throw 'New password is too weak';
        default:
          throw e.message ?? 'An error occurred while changing password';
      }
    } catch (e) {
      throw 'Failed to change password';
    }
  }

  // Add this method to verify password before deletion
  Future<void> verifyPassword({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Verify credentials without actually reauthenticating
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw 'Current password is incorrect';
        default:
          throw e.message ?? 'An error occurred while verifying password';
      }
    } catch (e) {
      throw 'Failed to verify password';
    }
  }
} 