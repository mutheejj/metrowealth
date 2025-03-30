import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';
import '../../../categories/data/repositories/category_repository.dart';

class TransactionRepository {
  final String userId;
  final CollectionReference<Map<String, dynamic>> _transactionsCollection;
  final CategoryRepository _categoryRepository;

  TransactionRepository(this.userId) 
      : _transactionsCollection = FirebaseFirestore.instance
            .collection('transactions')
            .withConverter<Map<String, dynamic>>(
              fromFirestore: (snapshot, _) => snapshot.data() ?? {},
              toFirestore: (data, _) => data,
            ),
        _categoryRepository = CategoryRepository(userId);

  // Get all transactions for the current user
  Stream<List<TransactionModel>> getTransactions() {
    return getTransactionsStream();
  }

  // Get all transactions for the current user (legacy method)
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Get transactions by category
  Stream<List<TransactionModel>> getTransactionsByCategory(String categoryId) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Get transactions by type
  Stream<List<TransactionModel>> getTransactionsByType(TransactionType type) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Get transactions by date range
  Stream<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Add a new transaction
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // Create a new document reference
      final docRef = _transactionsCollection.doc();
      
      // Create the transaction with the current user ID
      final newTransaction = transaction.copyWith(
        id: docRef.id,
        userId: userId,
        createdAt: DateTime.now(),
      );

      // Create the transaction data
      final transactionData = newTransaction.toMap();
      
      // Add the transaction
      batch.set(docRef, transactionData);

      // Update user's balance based on transaction type
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      
      if (transaction.type == TransactionType.expense) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(-transaction.amount),
          'statistics.totalExpenses': FieldValue.increment(transaction.amount),
        });
        
        // Update category spent amount
        await _categoryRepository.updateCategorySpentAmount(
          transaction.categoryId,
          transaction.amount,
        );
      } else if (transaction.type == TransactionType.income) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(transaction.amount),
          'statistics.totalIncome': FieldValue.increment(transaction.amount),
        });
      }
      
      await batch.commit();
      return newTransaction;
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(
    TransactionModel oldTransaction,
    TransactionModel newTransaction,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Ensure the transaction belongs to the current user
      if (oldTransaction.userId != userId) {
        throw Exception('Cannot update transaction: Permission denied');
      }

      // Update the transaction with the current timestamp
      final updatedTransaction = newTransaction.copyWith(
        updatedAt: DateTime.now(),
        userId: userId,
      );
      
      batch.update(
        _transactionsCollection.doc(updatedTransaction.id),
        updatedTransaction.toMap(),
      );

      // Update user's balance based on transaction types
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      
      // Revert old transaction's effect on balance
      if (oldTransaction.type == TransactionType.expense) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(oldTransaction.amount),
          'statistics.totalExpenses': FieldValue.increment(-oldTransaction.amount),
        });
        await _categoryRepository.updateCategorySpentAmount(
          oldTransaction.categoryId,
          -oldTransaction.amount,
        );
      } else if (oldTransaction.type == TransactionType.income) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(-oldTransaction.amount),
          'statistics.totalIncome': FieldValue.increment(-oldTransaction.amount),
        });
      }

      // Apply new transaction's effect on balance
      if (updatedTransaction.type == TransactionType.expense) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(-updatedTransaction.amount),
          'statistics.totalExpenses': FieldValue.increment(updatedTransaction.amount),
        });
        await _categoryRepository.updateCategorySpentAmount(
          updatedTransaction.categoryId,
          updatedTransaction.amount,
        );
      } else if (updatedTransaction.type == TransactionType.income) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(updatedTransaction.amount),
          'statistics.totalIncome': FieldValue.increment(updatedTransaction.amount),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    try {
      // Ensure the transaction belongs to the current user
      if (transaction.userId != userId) {
        throw Exception('Cannot delete transaction: Permission denied');
      }

      final batch = FirebaseFirestore.instance.batch();

      // Delete the transaction
      batch.delete(_transactionsCollection.doc(transaction.id));

      // Update user's balance based on transaction type
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      
      if (transaction.type == TransactionType.expense) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(transaction.amount),
          'statistics.totalExpenses': FieldValue.increment(-transaction.amount),
        });
        
        // Update category spent amount
        await _categoryRepository.updateCategorySpentAmount(
          transaction.categoryId,
          -transaction.amount,
        );
      } else if (transaction.type == TransactionType.income) {
        batch.update(userRef, {
          'totalBalance': FieldValue.increment(-transaction.amount),
          'statistics.totalIncome': FieldValue.increment(-transaction.amount),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get total income for a period
  Future<double> getTotalIncome({DateTime? startDate, DateTime? endDate}) async {
    var query = _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: TransactionType.income.toString().split('.').last);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.fold<double>(
      0.0,
      (sum, doc) {
        final data = doc.data();
        return sum + (data['amount'] as num? ?? 0.0).toDouble();
      },
    );
  }

  // Get total expenses for a period
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    var query = _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: TransactionType.expense.toString().split('.').last);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.fold<double>(
      0.0,
      (sum, doc) {
        final data = doc.data();
        return sum + (data['amount'] as num? ?? 0.0).toDouble();
      },
    );
  }

  // Get spending by category
  Future<Map<String, double>> getSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: TransactionType.expense.toString().split('.').last);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final spending = <String, double>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final categoryId = data['categoryId'] as String? ?? '';
        if (categoryId.isNotEmpty) {
          final amount = (data['amount'] as num? ?? 0.0).toDouble();
          spending[categoryId] = (spending[categoryId] ?? 0.0) + amount;
        }
      }

      return spending;
    } catch (e) {
      print('Error getting spending by category: $e');
      return {};
    }
  }

  // Get recurring transactions
  Stream<List<TransactionModel>> getRecurringTransactions() {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('frequency', isNotEqualTo: TransactionFrequency.oneTime.toString().split('.').last)
        .orderBy('frequency')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }
}