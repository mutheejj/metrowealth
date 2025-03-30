import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsAccountModel {
  final String id;
  final String userId;
  final String accountName;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsAccountModel({
    required this.id,
    required this.userId,
    required this.accountName,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsAccountModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavingsAccountModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      accountName: data['accountName'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'accountName': accountName,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  Map<String, dynamic> toMap() => toFirestore();
}