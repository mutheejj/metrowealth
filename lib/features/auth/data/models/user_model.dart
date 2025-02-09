import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String? fullName;
  final String email;
  final double balance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final String? photoUrl;
  final String? mobileNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final double totalBalance;
  final double savingsBalance;
  final double loanBalance;
  final DateTime? lastUpdated;
  final String? fcmToken;
  final Map<String, dynamic>? statistics;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.fullName,
    required this.email,
    this.balance = 0.0,
    this.monthlyIncome = 0.0,
    this.monthlyExpenses = 0.0,
    this.photoUrl,
    this.mobileNumber,
    this.dateOfBirth,
    this.address,
    this.totalBalance = 0.0,
    this.savingsBalance = 0.0,
    this.loanBalance = 0.0,
    this.lastUpdated,
    this.fcmToken,
    this.statistics,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      fullName: data['fullName'],
      email: data['email'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      monthlyIncome: (data['monthlyIncome'] ?? 0.0).toDouble(),
      monthlyExpenses: (data['monthlyExpenses'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'],
      mobileNumber: data['mobileNumber'],
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      address: data['address'],
      totalBalance: (data['totalBalance'] ?? 0.0).toDouble(),
      savingsBalance: (data['savingsBalance'] ?? 0.0).toDouble(),
      loanBalance: (data['loanBalance'] ?? 0.0).toDouble(),
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
      fcmToken: data['fcmToken'],
      statistics: data['statistics'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'balance': balance,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'photoUrl': photoUrl,
      'mobileNumber': mobileNumber,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'totalBalance': totalBalance,
      'savingsBalance': savingsBalance,
      'loanBalance': loanBalance,
      'lastUpdated': lastUpdated,
      'fcmToken': fcmToken,
      'statistics': statistics,
      'createdAt': createdAt,
    };
  }
} 