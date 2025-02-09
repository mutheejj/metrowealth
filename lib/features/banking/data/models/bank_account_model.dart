import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccountModel {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String accountType;
  final double balance;
  final bool isDefault;
  final DateTime linkedAt;

  BankAccountModel({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    this.isDefault = false,
    required this.linkedAt,
  });

  factory BankAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BankAccountModel(
      id: doc.id,
      userId: data['userId'],
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      accountType: data['accountType'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      isDefault: data['isDefault'] ?? false,
      linkedAt: data['linkedAt'] is Timestamp 
          ? (data['linkedAt'] as Timestamp).toDate()
          : DateTime.parse(data['linkedAt'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'isDefault': isDefault,
      'linkedAt': linkedAt,
    };
  }
} 