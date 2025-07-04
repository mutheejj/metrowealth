import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:metrowealth/features/banking/data/models/bank_account_model.dart';
import 'package:metrowealth/features/loans/data/models/loan_model.dart';
import 'package:metrowealth/features/savings/data/models/savings_account_model.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';


class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get transactions for a user within a date range
  Future<List<TransactionModel>> getTransactions(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      rethrow;
    }
  }

  // Get category budgets for a user
  Future<Map<String, num>> getCategoryBudgets(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      final budgets = <String, num>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('budget')) {
          budgets[doc.id] = data['budget'] as num;
        }
      }
      return budgets;
    } catch (e) {
      debugPrint('Error fetching category budgets: $e');
      rethrow;
    }
  }

  // Create default categories for new users
  Future<void> _createDefaultCategories(String userId) async {
    try {
      final batch = _db.batch();
      final categoriesRef = _db.collection('users').doc(userId).collection('categories');


      final defaultCategories = [
        {'name': 'Food & Dining', 'icon': 'restaurant', 'budget': 0.0},
        {'name': 'Transportation', 'icon': 'directions_car', 'budget': 0.0},
        {'name': 'Shopping', 'icon': 'shopping_bag', 'budget': 0.0},
        {'name': 'Bills & Utilities', 'icon': 'receipt', 'budget': 0.0},
        {'name': 'Entertainment', 'icon': 'movie', 'budget': 0.0},
        {'name': 'Healthcare', 'icon': 'medical_services', 'budget': 0.0},
        {'name': 'Education', 'icon': 'school', 'budget': 0.0},
        {'name': 'Savings', 'icon': 'savings', 'budget': 0.0},
      ];

      for (var category in defaultCategories) {
        final docRef = categoriesRef.doc();
        batch.set(docRef, {
          ...category,
          'id': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error creating default categories: $e');
      rethrow;
    }
  }

  // Create user profile with initial setup
  Future<void> createUserProfile(UserModel user) async {
    try {
      debugPrint('Starting user profile creation for ID: ${user.id}');
      
      // Create basic user document first
      await _db.collection('users').doc(user.id).set({
        'id': user.id,
        'fullName': user.fullName,
        'email': user.email,
      });

      debugPrint('Basic user profile created successfully');

      // Now update with additional data
      await _db.collection('users').doc(user.id).update({
        'mobileNumber': user.mobileNumber,
        'dateOfBirth': user.dateOfBirth?.toIso8601String(),
        'photoUrl': user.photoUrl,
        'address': user.address,
        'totalBalance': 0.0,
        'savingsBalance': 0.0,
        'loanBalance': 0.0,
        'linkedBankAccounts': [],
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
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('User profile updated with additional data');
      
      // Create default categories
      await _createDefaultCategories(user.id);
      debugPrint('Default categories created');
      
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  // Users Collection
  Future<void> createUserProfileOld(UserModel user) async {
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
              .map((doc) => TransactionModel.fromFirestore(doc))
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
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Get user transactions by date range
  Stream<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Helper method to get transactions as Future
  Future<List<TransactionModel>> getTransactionsByDateRangeAsFuture(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TransactionModel.fromMap({
        ...data,
        'id': doc.id,
      });
    }).toList();
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

  // Profile Photo Upload
  Future<String> uploadProfilePhoto(String userId, File photo) async {
    try {
      // Create a reference to the photo location
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      
      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );
      
      // Start upload
      final uploadTask = ref.putFile(photo, metadata);
      
      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      await uploadTask;
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      // Update user profile with photo URL
      await _db.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      rethrow;
    }
  }

  // Bank Account Methods
  Future<void> linkBankAccount(BankAccountModel account) async {
    try {
      await _db.collection('bank_accounts').doc(account.id).set(account.toMap());
      
      // Update user's linked accounts
      await _db.collection('users').doc(account.userId).update({
        'linkedBankAccounts': FieldValue.arrayUnion([account.id])
      });
    } catch (e) {
      debugPrint('Error linking bank account: $e');
      rethrow;
    }
  }

  // Loan Methods
  Future<void> applyForLoan(LoanModel loan) async {
    try {
      await _db.collection('loans').doc(loan.id).set(loan.toMap());
    } catch (e) {
      debugPrint('Error applying for loan: $e');
      rethrow;
    }
  }

  Future<void> updateLoanStatus(String loanId, LoanStatus status) async {
    try {
      await _db.collection('loans').doc(loanId).update({
        'status': status.toString(),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating loan status: $e');
      rethrow;
    }
  }

  // Savings Methods
  Future<void> createSavingsAccount(SavingsAccountModel account) async {
    try {
      await _db.collection('savings_accounts').doc(account.id).set(account.toMap());
    } catch (e) {
      debugPrint('Error creating savings account: $e');
      rethrow;
    }
  }

  Future<void> updateSavingsBalance(
    String accountId, 
    double amount, 
    bool isDeposit
  ) async {
    try {
      final account = await _db.collection('savings_accounts').doc(accountId).get();
      
      if (!account.exists) throw 'Savings account not found';
      
      double currentBalance = account.data()?['balance'] ?? 0.0;
      double newBalance = isDeposit 
          ? currentBalance + amount 
          : currentBalance - amount;

      if (!isDeposit && newBalance < 0) {
        throw 'Insufficient funds';
      }

      await _db.collection('savings_accounts').doc(accountId).update({
        'balance': newBalance,
        'transactionHistory': FieldValue.arrayUnion([
          {
            'amount': amount,
            'type': isDeposit ? 'deposit' : 'withdrawal',
            'timestamp': DateTime.now().toIso8601String(),
          }
        ])
      });

      // Update user's total balance
      await _db.collection('users').doc(account.data()?['userId']).update({
        'savingsBalance': FieldValue.increment(isDeposit ? amount : -amount),
      });
    } catch (e) {
      debugPrint('Error updating savings balance: $e');
      rethrow;
    }
  }

  // Transaction Methods with Categories
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      final batch = _db.batch();
      
      // Add transaction document
      final transactionRef = _db.collection('transactions').doc(transaction.id);
      batch.set(transactionRef, transaction.toMap());

      // Update user balances based on transaction type
      final userRef = _db.collection('users').doc(transaction.userId);
      
      switch (transaction.type) {
        case TransactionType.expense:
          batch.update(userRef, {
            'totalBalance': FieldValue.increment(-transaction.amount),
            'statistics.totalExpenses': FieldValue.increment(transaction.amount),
          });
          break;
        case TransactionType.income:
          batch.update(userRef, {
            'totalBalance': FieldValue.increment(transaction.amount),
            'statistics.totalIncome': FieldValue.increment(transaction.amount),
          });
          break;
        case TransactionType.transfer:
          if (transaction.recipientId != null) {
            final recipientRef = _db.collection('users').doc(transaction.recipientId);
            batch.update(userRef, {
              'totalBalance': FieldValue.increment(-transaction.amount),
            });
            batch.update(recipientRef, {
              'totalBalance': FieldValue.increment(transaction.amount),
            });
          }
          break;
        case TransactionType.savingsDeposit:
          batch.update(userRef, {
            'savingsBalance': FieldValue.increment(transaction.amount),
            'totalBalance': FieldValue.increment(-transaction.amount),
          });
          break;
        case TransactionType.savingsWithdrawal:
          batch.update(userRef, {
            'savingsBalance': FieldValue.increment(-transaction.amount),
            'totalBalance': FieldValue.increment(transaction.amount),
          });
          break;
        case TransactionType.loanPayment:
          batch.update(userRef, {
            'loanBalance': FieldValue.increment(-transaction.amount),
            'totalBalance': FieldValue.increment(-transaction.amount),
          });
          break;
        case TransactionType.loanDisbursement:
          batch.update(userRef, {
            'loanBalance': FieldValue.increment(transaction.amount),
            'totalBalance': FieldValue.increment(transaction.amount),
          });
          break;
        case TransactionType.billPayment:
          batch.update(userRef, {
            'totalBalance': FieldValue.increment(-transaction.amount),
            'statistics.totalExpenses': FieldValue.increment(transaction.amount),
          });
          break;
        default:
          batch.update(userRef, {
            'totalBalance': FieldValue.increment(-transaction.amount),
          });
          break;
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      rethrow;
    }
  }

  // Get user stream
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // Savings Goals Methods
  Future<void> createSavingsGoal(SavingsGoalModel goal) async {
    await _db.collection('savings_goals').doc(goal.id).set(goal.toFirestore());
  }

  Stream<List<SavingsGoalModel>> getSavingsGoals(String userId) {
    return _db
        .collection('savings_goals')
        .where('userId', isEqualTo: userId)
        .orderBy('targetDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingsGoalModel.fromFirestore(doc))
            .toList());
  }
  
  // Statistics Methods
  Future<Map<String, dynamic>> getMonthlyStatistics(
    String userId,
    DateTime month,
  ) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);
  
      // Get transactions using the Future version
      final transactions = await getTransactionsByDateRangeAsFuture(
        userId,
        startDate,
        endDate,
      );
  
      // Calculate statistics
      double totalIncome = 0;
      double totalExpenses = 0;
      Map<String, double> categoryTotals = {};
  
      for (var transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpenses += transaction.amount;
          categoryTotals[transaction.categoryId] =
              (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
        }
      }
  
      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'categoryTotals': categoryTotals,
        'savingsRate': totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome : 0,
      };
    } catch (e) {
      debugPrint('Error getting monthly statistics: $e');
      rethrow;
    }
  }
  
  // User Methods
  Future<UserModel?> getCurrentUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
  
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
  
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      rethrow;
    }
  }
  
  // Financial Overview Methods
  Future<Map<String, dynamic>> getFinancialOverview(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
      final transactionsQuery = await _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();
  
      double totalIncome = 0;
      double totalExpenses = 0;
      Map<String, double> categorySpending = {};
  
      for (var doc in transactionsQuery.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpenses += transaction.amount;
          categorySpending[transaction.categoryId] = 
              (categorySpending[transaction.categoryId] ?? 0) + transaction.amount;
        }
      }
  
      // Get savings goals progress
      final savingsQuery = await _db
          .collection('savingsGoals')
          .where('userId', isEqualTo: userId)
          .get();
  
      double totalSavings = 0;
      double savingsTargets = 0;
  
      for (var doc in savingsQuery.docs) {
        final goal = SavingsGoalModel.fromFirestore(doc);
        totalSavings += goal.currentAmount;
        savingsTargets += goal.targetAmount;
      }
  
      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'categorySpending': categorySpending,
        'totalSavings': totalSavings,
        'savingsTargets': savingsTargets,
        'netIncome': totalIncome - totalExpenses,
        'savingsRate': totalIncome > 0 ? (totalSavings / totalIncome) * 100 : 0,
      };
    } catch (e) {
      debugPrint('Error getting financial overview: $e');
      rethrow;
    }
  }

  // Transaction Methods
  Future<List<TransactionModel>> getRecentTransactions(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final query = await _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
  
      return query.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting recent transactions: $e');
      rethrow;
    }
  }

  // Spending Insights Methods
  Future<Map<String, dynamic>> getSpendingInsights(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .where('type', isEqualTo: TransactionType.expense.toString())
          .get();
  
      Map<String, double> categorySpending = {};
      Map<String, List<TransactionModel>> categoryTransactions = {};
  
      for (var doc in query.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        categorySpending[transaction.categoryId] = 
            (categorySpending[transaction.categoryId] ?? 0) + transaction.amount;
        
        categoryTransactions[transaction.categoryId] = 
            (categoryTransactions[transaction.categoryId] ?? [])..add(transaction);
      }
  
      return {
        'categorySpending': categorySpending,
        'categoryTransactions': categoryTransactions,
      };
    } catch (e) {
      debugPrint('Error getting spending insights: $e');
      rethrow;
    }
  }

  Future<void> processPayment({
    required double amount,
    required String fromAccount,
    required String title,
    String? billId,
  }) async {
    try {
      final batch = _db.batch();
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';
  
      // Create transaction record
      final transactionRef = _db.collection('transactions').doc();
      batch.set(transactionRef, {
        'userId': uid,
        'amount': amount,
        'type': TransactionType.expense.toString(),
        'category': 'Bills',
        'title': title,
        'date': DateTime.now(),
        'accountId': fromAccount,
        'billId': billId,
      });
  
      // Update account balance
      final accountRef = _db.collection('bankAccounts').doc(fromAccount);
      batch.update(accountRef, {
        'balance': FieldValue.increment(-amount),
      });
  
      // If this is a bill payment, update bill status
      if (billId != null) {
        final billRef = _db.collection('bills').doc(billId);
        batch.update(billRef, {
          'status': 'paid',
          'paidDate': DateTime.now(),
        });
      }
  
      await batch.commit();
    } catch (e) {
      debugPrint('Error processing payment: $e');
      rethrow;
    }
  }

  Future<List<BankAccountModel>> getUserBankAccounts() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';
  
      final snapshot = await _db
          .collection('bankAccounts')
          .where('userId', isEqualTo: uid)
          .get();
  
      return snapshot.docs
          .map((doc) => BankAccountModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user bank accounts: $e');
      rethrow;
    }
  }



  Future<Map<String, double>> getSpendingByCategory(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
  
      final spending = <String, double>{};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final categoryId = data['categoryId'] as String;
        final amount = (data['amount'] as num).toDouble();
        spending[categoryId] = (spending[categoryId] ?? 0) + amount;
      }
      return spending;
    } catch (e) {
      debugPrint('Error getting spending by category: $e');
      return {};
    }
  }

  Future<double> getTotalBudget(String userId) async {
    try {
      final snapshot = await _db
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();
  
      return snapshot.docs.fold<double>(
        0.0,
        (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + ((data['budget'] as num?)?.toDouble() ?? 0.0);
        },
      );
    } catch (e) {
      debugPrint('Error getting total budget: $e');
      return 0.0;
    }
  }

  // Get transactions by period (Daily, Weekly, Monthly, Year)
  Future<List<dynamic>> getTransactionsByPeriod(String period, DateTime startDate, DateTime endDate) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';
  
      var query = _db
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true);
  
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'date': (data['date'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting transactions by period: $e');
      return [];
    }
  }
}