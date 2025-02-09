import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? mobileNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final double totalBalance;
  final double savingsBalance;
  final double loanBalance;
  final List<String> linkedBankAccounts;
  final Map<String, dynamic> notificationSettings;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String? fcmToken; // For push notifications

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.mobileNumber,
    this.dateOfBirth,
    this.address,
    this.totalBalance = 0.0,
    this.savingsBalance = 0.0,
    this.loanBalance = 0.0,
    List<String>? linkedBankAccounts,
    Map<String, dynamic>? notificationSettings,
    required this.createdAt,
    this.lastUpdated,
    this.fcmToken,
  })  : linkedBankAccounts = linkedBankAccounts ?? [],
        notificationSettings = notificationSettings ?? {
          'pushEnabled': true,
          'emailEnabled': true,
          'transactionAlerts': true,
          'savingsReminders': true,
          'loanReminders': true,
          'budgetAlerts': true,
        };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'mobileNumber': mobileNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'totalBalance': totalBalance,
      'savingsBalance': savingsBalance,
      'loanBalance': loanBalance,
      'linkedBankAccounts': linkedBankAccounts,
      'notificationSettings': notificationSettings,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      mobileNumber: map['mobileNumber'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] is Timestamp 
              ? (map['dateOfBirth'] as Timestamp).toDate()
              : DateTime.parse(map['dateOfBirth']))
          : null,
      address: map['address'],
      totalBalance: map['totalBalance']?.toDouble() ?? 0.0,
      savingsBalance: map['savingsBalance']?.toDouble() ?? 0.0,
      loanBalance: map['loanBalance']?.toDouble() ?? 0.0,
      linkedBankAccounts: List<String>.from(map['linkedBankAccounts'] ?? []),
      notificationSettings: Map<String, dynamic>.from(
          map['notificationSettings'] ?? {}),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      lastUpdated: map['lastUpdated'] != null 
          ? (map['lastUpdated'] is Timestamp 
              ? (map['lastUpdated'] as Timestamp).toDate()
              : DateTime.parse(map['lastUpdated']))
          : null,
      fcmToken: map['fcmToken'],
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? photoUrl,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? address,
    double? totalBalance,
    double? savingsBalance,
    double? loanBalance,
    List<String>? linkedBankAccounts,
    Map<String, dynamic>? notificationSettings,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      totalBalance: totalBalance ?? this.totalBalance,
      savingsBalance: savingsBalance ?? this.savingsBalance,
      loanBalance: loanBalance ?? this.loanBalance,
      linkedBankAccounts: linkedBankAccounts ?? this.linkedBankAccounts,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
} 