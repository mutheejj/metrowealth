import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  expense,
  income,
  transfer,
  deposit,
  withdrawal,
  savingsDeposit,
  savingsWithdrawal,
  loanPayment,
  loanDisbursement,
  billPayment,
  investment
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  reversed
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;
  final String? attachmentUrl;
  final TransactionStatus status;
  final String? referenceNumber;
  final String? recipientId;  // For transfers
  final String? accountId;    // Source/destination account
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    this.attachmentUrl,
    required this.status,
    this.referenceNumber,
    this.recipientId,
    this.accountId,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString(),
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'status': status.toString(),
      'referenceNumber': referenceNumber,
      'recipientId': recipientId,
      'accountId': accountId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] == 'TransactionType.expense' 
          ? TransactionType.expense 
          : map['type'] == 'TransactionType.income' 
              ? TransactionType.income 
              : map['type'] == 'TransactionType.transfer' 
                  ? TransactionType.transfer 
                  : map['type'] == 'TransactionType.deposit' 
                      ? TransactionType.deposit 
                      : map['type'] == 'TransactionType.withdrawal' 
                          ? TransactionType.withdrawal 
                          : map['type'] == 'TransactionType.savingsDeposit' 
                              ? TransactionType.savingsDeposit 
                              : map['type'] == 'TransactionType.savingsWithdrawal' 
                                  ? TransactionType.savingsWithdrawal 
                                  : map['type'] == 'TransactionType.loanPayment' 
                                      ? TransactionType.loanPayment 
                                      : map['type'] == 'TransactionType.loanDisbursement' 
                                          ? TransactionType.loanDisbursement 
                                          : map['type'] == 'TransactionType.billPayment' 
                                              ? TransactionType.billPayment 
                                              : TransactionType.investment,
      category: map['category'] ?? '',
      description: map['description'],
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      attachmentUrl: map['attachmentUrl'],
      status: map['status'] == 'TransactionStatus.pending' 
          ? TransactionStatus.pending 
          : map['status'] == 'TransactionStatus.completed' 
              ? TransactionStatus.completed 
              : map['status'] == 'TransactionStatus.failed' 
                  ? TransactionStatus.failed 
                  : map['status'] == 'TransactionStatus.cancelled' 
                      ? TransactionStatus.cancelled 
                      : TransactionStatus.reversed,
      referenceNumber: map['referenceNumber'],
      recipientId: map['recipientId'],
      accountId: map['accountId'],
      metadata: map['metadata'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt']),
    );
  }
} 