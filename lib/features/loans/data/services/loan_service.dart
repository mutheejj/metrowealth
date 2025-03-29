import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitLoanApplication(Map<String, dynamic> loanData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // Add user information to loan data
      loanData['userId'] = user.uid;
      loanData['userEmail'] = user.email;
      loanData['status'] = 'pending';
      loanData['submittedAt'] = FieldValue.serverTimestamp();

      // Calculate monthly installment
      final amount = loanData['amount'] as double;
      final tenure = loanData['tenure'] as int;
      final interestRate = loanData['interestRate'] as double;
      final monthlyInterest = interestRate / 12 / 100;
      final monthlyInstallment = (amount * monthlyInterest * pow((1 + monthlyInterest), tenure)) /
          (pow((1 + monthlyInterest), tenure) - 1);

      loanData['monthlyInstallment'] = monthlyInstallment;
      loanData['totalRepayment'] = monthlyInstallment * tenure;

      // Submit to Firestore
      await _db.collection('loans').add(loanData);

      // Update user's active loans count
      await _db.collection('users').doc(user.uid).update({
        'activeLoans': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error submitting loan application: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserLoans(String userId) async {
    try {
      final snapshot = await _db
          .collection('loans')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'pending', 'approved'])
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Error getting user loans: $e');
      return [];
    }
  }

  Future<bool> isEligibleForLoan(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      final userData = userDoc.data();
      if (userData == null) return false;

      final activeLoans = userData['activeLoans'] as int? ?? 0;
      return activeLoans < 2; // Maximum 2 active loans allowed
    } catch (e) {
      debugPrint('Error checking loan eligibility: $e');
      return false;
    }
  }
}