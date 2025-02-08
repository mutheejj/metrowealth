import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Users Collection
  Future<void> createUserProfile(UserModel user) async {
    try {
      // Wait for authentication to be ready and retry a few times if needed
      int retries = 5; // Increased retries
      User? currentUser;
      
      while (retries > 0 && currentUser == null) {
        currentUser = _auth.currentUser;
        if (currentUser == null) {
          await Future.delayed(const Duration(milliseconds: 500)); // Reduced delay
          retries--;
        }
      }

      if (currentUser == null || currentUser.uid != user.id) {
        throw 'Authentication failed after multiple retries';
      }

      // Create user document
      final userDoc = _db.collection('users').doc(user.id);
      
      // First, check if the document already exists
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        debugPrint('User document already exists');
        return;
      }

      // Create the document
      await userDoc.set({
        'id': user.id,
        'fullName': user.fullName,
        'email': user.email,
        'mobileNumber': user.mobileNumber,
        'dateOfBirth': user.dateOfBirth?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'settings': {
          'currency': 'KES',
          'theme': 'light',
          'notifications': {
            'transactions': true,
            'budgetAlerts': true,
            'goals': true,
          },
        },
        'statistics': {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'monthlyBudget': 0.0,
          'savingsGoal': 0.0,
        }
      });

      // Create categories after user document is created
      await _createDefaultCategories(user.id);
      
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> _createDefaultCategories(String userId) async {
    try {
      final categoriesRef = _db
          .collection('users')
          .doc(userId)
          .collection('categories');

      // Create categories in a batch
      final batch = _db.batch();
      
      for (var category in _defaultCategories) {
        final docRef = categoriesRef.doc();
        batch.set(docRef, {
          ...category,
          'id': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error creating categories: $e');
      rethrow;
    }
  }

  // Default categories list
  static const _defaultCategories = [
    {
      'name': 'Food & Dining',
      'type': 'expense',
      'icon': 'restaurant',
      'budget': 0.0,
      'color': '#FF6B6B',
    },
    {
      'name': 'Transportation',
      'type': 'expense',
      'icon': 'directions_car',
      'budget': 0.0,
      'color': '#4ECDC4',
    },
    {
      'name': 'Shopping',
      'type': 'expense',
      'icon': 'shopping_bag',
      'budget': 0.0,
      'color': '#45B7D1',
    },
    {
      'name': 'Bills & Utilities',
      'type': 'expense',
      'icon': 'receipt',
      'budget': 0.0,
      'color': '#96CEB4',
    },
    {
      'name': 'Salary',
      'type': 'income',
      'icon': 'work',
      'budget': 0.0,
      'color': '#4CAF50',
    },
    {
      'name': 'Business',
      'type': 'income',
      'icon': 'business',
      'budget': 0.0,
      'color': '#2196F3',
    },
  ];

  // Add a transaction with category
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final batch = _db.batch();
      
      // Add transaction
      final transactionRef = _db
          .collection('users')
          .doc(transaction.userId)
          .collection('transactions')
          .doc();

      batch.set(transactionRef, {
        ...transaction.toMap(),
        'id': transactionRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user statistics
      final userRef = _db.collection('users').doc(transaction.userId);
      if (transaction.type == TransactionType.income) {
        batch.update(userRef, {
          'statistics.totalIncome': FieldValue.increment(transaction.amount),
        });
      } else {
        batch.update(userRef, {
          'statistics.totalExpenses': FieldValue.increment(transaction.amount),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  // Get user transactions with pagination
  Stream<List<TransactionModel>> getUserTransactions(String userId, {int limit = 20}) {
    try {
      return _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Error getting user transactions: $e');
      rethrow;
    }
  }

  // Get user categories
  Stream<QuerySnapshot> getUserCategories(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots();
  }

  // Add savings goal
  Future<void> addSavingsGoal(String userId, Map<String, dynamic> goal) async {
    try {
      final goalRef = _db
          .collection('users')
          .doc(userId)
          .collection('savings_goals')
          .doc();

      await goalRef.set({
        ...goal,
        'id': goalRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'progress': 0.0,
        'status': 'active',
      });
    } catch (e) {
      debugPrint('Error adding savings goal: $e');
      rethrow;
    }
  }

  // Update user settings
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _db.collection('users').doc(userId).update({
        'settings': settings,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user settings: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user transactions by date range
  Stream<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Error getting transactions by date range: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != user.id) {
        throw 'Authentication failed';
      }

      await _db.collection('users').doc(user.id).update({
        'fullName': user.fullName,
        'mobileNumber': user.mobileNumber,
        'dateOfBirth': user.dateOfBirth?.toIso8601String(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw 'User not found';
      
      // Delete user's transactions
      final transactionDocs = await _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();
          
      final batch = _db.batch();
      
      // Add transaction deletions to batch
      for (var doc in transactionDocs.docs) {
        batch.delete(doc.reference);
      }
      
      // Add user document deletion to batch
      batch.delete(_db.collection('users').doc(userId));
      
      // Execute all deletions in a single batch
      await batch.commit();
      
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }
} 