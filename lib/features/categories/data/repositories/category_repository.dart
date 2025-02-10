import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  CategoryRepository(this.userId);

  // Get user's categories collection reference
  CollectionReference get _categoriesCollection => 
      _firestore.collection('users').doc(userId).collection('categories');

  // Stream all categories
  Stream<List<CategoryModel>> getCategories() {
    return _categoriesCollection
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Stream categories by type
  Stream<List<CategoryModel>> getCategoriesByType(CategoryType type) {
    return _categoriesCollection
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Add new category
  Future<DocumentReference> addCategory(CategoryModel category) {
    return _categoriesCollection.add(category.toMap());
  }

  // Update category
  Future<void> updateCategory(CategoryModel category) {
    return _categoriesCollection.doc(category.id).update(category.toMap());
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) {
    return _categoriesCollection.doc(categoryId).delete();
  }

  // Add transaction to category
  Future<void> addTransaction(String categoryId, TransactionModel transaction) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final updatedTransactions = [...categoryData.transactions, transaction];
    final newSpent = categoryData.spent + transaction.amount;
    
    return _categoriesCollection.doc(categoryId).update({
      'transactions': updatedTransactions.map((t) => t.toMap()).toList(),
      'spent': newSpent,
      'lastUpdated': Timestamp.now(),
    });
  }

  // Update transaction
  Future<void> updateTransaction(
    String categoryId, 
    TransactionModel oldTransaction,
    TransactionModel newTransaction
  ) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final updatedTransactions = categoryData.transactions.map((t) {
      if (t.id == oldTransaction.id) return newTransaction;
      return t;
    }).toList();
    
    final spentDifference = newTransaction.amount - oldTransaction.amount;
    final newSpent = categoryData.spent + spentDifference;
    
    return _categoriesCollection.doc(categoryId).update({
      'transactions': updatedTransactions.map((t) => t.toMap()).toList(),
      'spent': newSpent,
      'lastUpdated': Timestamp.now(),
    });
  }

  // Delete transaction
  Future<void> deleteTransaction(String categoryId, String transactionId) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final transaction = categoryData.transactions
        .firstWhere((t) => t.id == transactionId);
    final updatedTransactions = categoryData.transactions
        .where((t) => t.id != transactionId)
        .toList();
    final newSpent = categoryData.spent - transaction.amount;
    
    return _categoriesCollection.doc(categoryId).update({
      'transactions': updatedTransactions.map((t) => t.toMap()).toList(),
      'spent': newSpent,
      'lastUpdated': Timestamp.now(),
    });
  }

  // Update budget settings
  Future<void> updateBudgetSettings(
    String categoryId, 
    BudgetSettings settings
  ) {
    return _categoriesCollection.doc(categoryId).update({
      'budgetSettings': settings.toMap(),
      'lastUpdated': Timestamp.now(),
    });
  }

  // Get category spending for a time period
  Future<Map<String, double>> getCategorySpending(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final categories = await _categoriesCollection.get();
    final spending = <String, double>{};
    
    for (var doc in categories.docs) {
      final category = CategoryModel.fromFirestore(doc);
      final transactions = category.getTransactionsByDateRange(startDate, endDate);
      spending[category.id] = transactions.fold(
        0.0, 
        (sum, t) => sum + t.amount
      );
    }
    
    return spending;
  }

  // Initialize default categories for new user
  Future<void> initializeDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'food',
        name: 'Food',
        icon: 'e56c', // restaurant icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 500,
          warningThreshold: 80,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transport',
        icon: 'e530', // directions_bus icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 200,
          warningThreshold: 80,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'medicine',
        name: 'Medicine',
        icon: 'e3ed', // medical_services icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 100,
          warningThreshold: 90,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'groceries',
        name: 'Groceries',
        icon: 'e8cc', // shopping_bag icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 400,
          warningThreshold: 80,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'rent',
        name: 'Rent',
        icon: 'e88a', // house icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 1500,
          warningThreshold: 95,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'gifts',
        name: 'Gifts',
        icon: 'e8f6', // card_giftcard icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 100,
          warningThreshold: 80,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'savings',
        name: 'Savings',
        icon: 'e850', // savings icon
        color: Colors.blue,
        type: CategoryType.savings,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 1000,
          warningThreshold: 90,
        ),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        icon: 'e307', // local_activity icon
        color: Colors.blue,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        budgetSettings: BudgetSettings(
          monthlyLimit: 200,
          warningThreshold: 80,
        ),
        lastUpdated: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();
    
    for (var category in defaultCategories) {
      final docRef = _categoriesCollection.doc(category.id);
      batch.set(docRef, category.toMap());
    }

    return batch.commit();
  }

  // Get category statistics
  Future<Map<String, dynamic>> getCategoryStatistics(String categoryId) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);
    
    return {
      'dailyAverage': categoryData.dailyAverage,
      'monthlyTotal': categoryData.monthlyTotal,
      'monthOverMonthGrowth': categoryData.monthOverMonthGrowth,
      'yearToDate': categoryData.getTransactionsByDateRange(yearStart, now)
          .fold(0.0, (sum, t) => sum + t.amount),
      'recurringTransactions': categoryData.getRecurringTransactions().length,
      'totalTransactions': categoryData.transactions.length,
      'lastTransaction': categoryData.transactions.isNotEmpty 
          ? categoryData.transactions.first 
          : null,
    };
  }
} 