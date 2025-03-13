import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersCount = await _db.collection('users').count().get();
      final transactionsQuery = await _db.collection('transactions').get();
      final loansQuery = await _db.collection('loans').where('status', isEqualTo: 'active').get();
      
      double totalRevenue = 0;
      for (var doc in transactionsQuery.docs) {
        final data = doc.data();
        if (data['type'] == 'income') {
          totalRevenue += (data['amount'] as num).toDouble();
        }
      }

      return {
        'totalUsers': usersCount.count,
        'totalTransactions': transactionsQuery.docs.length,
        'activeLoans': loansQuery.docs.length,
        'revenue': totalRevenue,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      rethrow;
    }
  }

  // User Management
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      await _db.collection('users').doc(userData['uid']).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'user',
      });
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _db.collection('users').doc(userId).update({
        'isActive': isActive,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
      rethrow;
    }
  }

  // Transaction Management
  Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Loan Management
  Stream<QuerySnapshot> getLoansStream() {
    return _db
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateLoanStatus(String loanId, String status) async {
    try {
      await _db.collection('loans').doc(loanId).update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating loan status: $e');
      rethrow;
    }
  }

  // Reports
  Future<Map<String, dynamic>> getMonthlyReport(DateTime date) async {
    try {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0);

      final transactionsQuery = await _db
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalIncome = 0;
      double totalExpenses = 0;
      for (var doc in transactionsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['type'] == 'income') {
          totalIncome += (data['amount'] as num).toDouble();
        } else {
          totalExpenses += (data['amount'] as num).toDouble();
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'netIncome': totalIncome - totalExpenses,
        'transactionCount': transactionsQuery.docs.length,
        'period': '${date.year}-${date.month.toString().padLeft(2, '0')}',
      };
    } catch (e) {
      debugPrint('Error getting monthly report: $e');
      rethrow;
    }
  }
}